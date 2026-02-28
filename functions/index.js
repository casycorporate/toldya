const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Cloud Functions ortamında default app yoksa hemen başlat (soğuk start'ta "default app does not exist" önlenir).
if (!admin.apps.length) {
  const dbUrl = process.env.DATABASE_URL || functions.config().db?.url;
  if (dbUrl) {
    admin.initializeApp({ databaseURL: dbUrl });
  } else {
    admin.initializeApp();
  }
}

let _db = null;
function getDb() {
  if (!_db) {
    _db = admin.database();
  }
  return _db;
}

// --- TEST AŞAMASI: Tüm işler MANUEL (HTTP). Dört ayrı sorumluluk ---
// 1) Yayın kontrolü: runAiModeration           → statu=6 → AI ile onay/red (0 veya 7)
// 2) Kilit:          runLockPredictions        → endDate geçen Live tahminleri statu=5 (Locked)
// 3) Sonuçlandırma:  runOracleResolution       → oracle API ile feedResult + statu=Ok
// 4) Dağıtım:        runDistributeWinnings    → sonuçlanmış tahminlerde kazanç payı
// Schedule yok; Production'da zamanlanmış sürümler tekrar eklenir.

// Statu değerleri (lib/helper/constant.dart ile uyumlu)
const STATU_LIVE = 0;
const STATU_LOCKED = 5;
const STATU_PENDING_AI_REVIEW = 6;
const STATU_REJECTED_BY_AI = 7;

const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";

/** Moderasyon icin kullanilacak modeller; once rastgele biri, red (7) gelirse sirayla digerleri denenir. */
const MODERATION_MODELS = [
  "liquid/lfm-2.5-1.2b-thinking:free",
  "nvidia/nemotron-3-nano-30b-a3b:free",
  "qwen/qwen3-coder:free",
  "google/gemini-3-flash-preview",
  "deepseek/deepseek-v3.2",
  "x-ai/grok-4.1-fast",
  "stepfun/step-3.5-flash:free",
];

/** Rastgele baslangic modeli, sonra sirayla digerleri (dondurulmus dizi). */
function getModerationModelOrder() {
  const list = [...MODERATION_MODELS];
  const start = Math.floor(Math.random() * list.length);
  return [...list.slice(start), ...list.slice(0, start)];
}

const MODERATION_SYSTEM_PROMPT = `Sen bir sosyal tahmin platformu moderatörüsün. Verilen metni şu kriterlere göre değerlendir:
1) Topluluk kurallarına uygun mu? (nefret, hakaret, yasadışı içerik yok)
2) Net ve tutarlı bir tahmin mi? (Evet/Hayır ile sonuçlanabilir, belirsiz veya anlamsız değil)
3) Tahmin hangi kategoriye girer? Sadece şunlardan birini seç: spor, eco, fun, politic (spor=spor/maç/sağlık, eco=ekonomi/şirket/piyasa, fun=eğlence/medya/sanat, politic=siyaset/hukuk/toplum)
4) onay true ise: Tahmin metninden ve baglamdan bahis kapanis ve sonuclanma tarihlerini cikar. endDate = bahislerin alinmayacagi son an (ISO 8601 UTC, ornek: 2025-03-01T18:00:00.000Z). resolutionDate = sonucun ilan edilecegi an, endDate'ten en az 1 saat sonra (ISO 8601 UTC).

Yanıtını SADECE şu JSON formatında ver, başka metin yazma:
{"onay": true veya false, "gerekce": "...", "kategori": "spor"|"eco"|"fun"|"politic", "endDate": "ISO8601 UTC veya bos", "resolutionDate": "ISO8601 UTC veya bos"}

ÖNEMLI: onay false ise gerekce alanını MUTLAKA doldur. onay true ise endDate ve resolutionDate ver (tahmin metninde tarih/saat varsa ona gore, yoksa makul varsayilan: simdiden 24 saat sonra kapanis, 25 saat sonra sonuclanma). Tarihleri ISO 8601 UTC olarak yaz.`;

const VALID_TOPICS = ["spor", "eco", "fun", "politic"];

const RESOLUTION_SYSTEM_PROMPT = `Sen bir tahmin sonuçlandırma asistanısın. Verilen tahmin metnini ve sonuçlanma zamanını dikkate alarak, tahminin GERÇEKLEŞİP GERÇEKLEŞMEDİĞİNE karar ver.
Evet/Hayır ile cevaplanabilir bir tahmin (örn. "Yarın yağmur yağacak mı?") için, bilinen gerçeklere veya makul çıkarıma göre yanıt ver.
Yanıtını SADECE şu JSON formatında ver, başka metin yazma: {"sonuc": 1} veya {"sonuc": 2}
- 1 = Evet (tahmin doğru çıktı)
- 2 = Hayır (tahmin yanlış çıktı veya gerçekleşmedi)`;

/** BOM (U+FEFF) ve 255+ kodlu karakterleri kaldırır; ByteString/Firebase hatasını önler. */
function safeString(str) {
  if (str == null) return "";
  let s = String(str).replace(/\uFEFF/g, "");
  let out = "";
  for (let i = 0; i < s.length; i++) {
    const code = s.charCodeAt(i);
    out += code <= 255 ? s[i] : " ";
  }
  return out;
}

/** Objeyi Firebase'e yazmadan önce tüm string değerleri temizler (iç içe dahil). */
function deepSanitize(val) {
  if (val == null) return val;
  if (typeof val === "string") return safeString(val);
  if (Array.isArray(val)) return val.map(deepSanitize);
  if (typeof val === "object") {
    const out = {};
    for (const [k, v] of Object.entries(val)) out[k] = deepSanitize(v);
    return out;
  }
  return val;
}

/**
 * OpenRouter API ile tek bir gönderi metnini moderasyon kontrolünden geçirir.
 * @param {string} description - Gönderi metni
 * @param {string} apiKey - OpenRouter API key
 * @param {string} model - Model ID (örn. openai/gpt-4o-mini)
 * @param {string} [referenceDateIso] - Kayıt tarihi (ISO); AI endDate/resolutionDate verirken bu yılı ve bu tarihten sonrasını kullanmalı
 * @returns {{ approved: boolean, reason?: string, ... }}
 */
async function moderateWithOpenRouter(description, apiKey, model, referenceDateIso) {
  const cleanKey = safeString(apiKey).replace(/\s/g, "").trim() || apiKey;
  const refDate = referenceDateIso ? new Date(referenceDateIso) : new Date();
  const refIso = referenceDateIso && !isNaN(refDate.getTime()) ? refDate.toISOString().slice(0, 10) : refDate.toISOString().slice(0, 10);
  const userContent = (safeString(description) || "(metin yok)")
    + `\n\n[ÖNEMLİ: Referans tarih (kayıt anı): ${refIso}. endDate ve resolutionDate MUTLAKA bu tarihten SONRA olmalı. Örn. "Nisan ay sonu" dersen ${refDate.getFullYear()}-04-30 kullan, geçmiş yıl kullanma.]`;
  const body = {
    model: safeString(model) || MODERATION_MODELS[0],
    messages: [
      { role: "system", content: safeString(MODERATION_SYSTEM_PROMPT) },
      { role: "user", content: userContent },
    ],
    max_tokens: 200,
    temperature: 0.2,
  };
  const res = await fetch(OPENROUTER_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${cleanKey}`,
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const errText = await res.text();
    throw new Error(safeString(`OpenRouter ${res.status}: ${errText}`));
  }
  const data = await res.json();
  const rawContent = data.choices?.[0]?.message?.content ?? "";
  const content = safeString(rawContent).trim() || "";
  try {
    const jsonMatch = content.match(/\{[\s\S]*\}/);
    const parsed = jsonMatch ? JSON.parse(jsonMatch[0]) : {};
    const onay = parsed.onay === true;
    let category = safeString(parsed.kategori || "").toLowerCase().trim();
    if (!VALID_TOPICS.includes(category)) category = "spor";
    const rawGerekce = parsed.gerekce;
    const gerekceStr = rawGerekce != null && String(rawGerekce).trim() !== "" ? String(rawGerekce).trim() : "";
    const reason = onay
      ? (safeString(gerekceStr) || "Uygun")
      : (safeString(gerekceStr) || "Red nedeni AI tarafindan yazilmadi. Olasi nedenler: topluluk kurallari (nefret/hakaret), tahmin Evet/Hayir ile sonuclanamiyor, belirsiz veya kategori uygun degil.");
    if (!onay && !gerekceStr) {
      console.warn("AI rejection without gerekce. Raw content:", rawContent);
    }
    let endDateIso = null;
    let resolutionDateIso = null;
    if (onay) {
      const rawEnd = parsed.endDate;
      const rawRes = parsed.resolutionDate;
      if (rawEnd != null && String(rawEnd).trim() !== "") endDateIso = String(rawEnd).trim();
      if (rawRes != null && String(rawRes).trim() !== "") resolutionDateIso = String(rawRes).trim();
    }
    return {
      approved: onay,
      reason,
      category,
      endDateIso: endDateIso || null,
      resolutionDateIso: resolutionDateIso || null,
    };
  } catch (e) {
    const lower = content.toLowerCase();
    const approved = lower.includes("\"onay\": true") || (lower.includes("evet") && !lower.includes("hayır"));
    return { approved, reason: "Yanıt ayrıştırılamadı", category: "spor", endDateIso: null, resolutionDateIso: null };
  }
}

/**
 * OpenRouter ile tahmin sonucu döndürür (oracleApiUrl yoksa kullanılır).
 * @returns {Promise<number|null>} 1 = Evet, 2 = Hayır, null = belirsiz/hata
 */
async function resolveWithOpenRouter(description, resolutionDate, apiKey, model) {
  if (!apiKey) return null;
  const cleanKey = safeString(apiKey).replace(/\s/g, "").trim() || apiKey;
  const userContent = `Tahmin: ${safeString(description) || "(yok)"}\nSonuçlanma zamanı: ${safeString(resolutionDate) || ""}\nBu tahmin gerçekleşti mi? Sadece JSON ver: {"sonuc": 1} veya {"sonuc": 2}`;
  const res = await fetch(OPENROUTER_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${cleanKey}`,
    },
    body: JSON.stringify({
      model: safeString(model) || MODERATION_MODELS[0],
      messages: [
        { role: "system", content: safeString(RESOLUTION_SYSTEM_PROMPT) },
        { role: "user", content: userContent },
      ],
      max_tokens: 100,
      temperature: 0.1,
    }),
  });
  if (!res.ok) return null;
  const data = await res.json();
  const rawContent = data.choices?.[0]?.message?.content ?? "";
  const content = safeString(rawContent).trim();
  const jsonMatch = content.match(/\{[\s\S]*\}/);
  if (!jsonMatch) return null;
  try {
    const parsed = JSON.parse(jsonMatch[0]);
    const sonuc = parsed.sonuc ?? parsed.result;
    if (sonuc === 1 || sonuc === 2) return sonuc;
  } catch (_) {}
  if (content.toLowerCase().includes("evet") && !content.toLowerCase().includes("hayır")) return 1;
  if (content.toLowerCase().includes("hayır")) return 2;
  return null;
}

/**
 * AI moderasyon mantığını çalıştırır (statu=6 → 0 veya 7).
 * Önce rastgele bir model denenir; red (7) gelirse sırayla diğer modeller denenir.
 */
async function runAiModerationLogic(apiKey) {
  if (!apiKey) {
    throw new Error(
      "OpenRouter API key tanımlı değil. Ayarlayın: firebase functions:secrets:set OPENROUTER_API_KEY"
    );
  }

  const toldyaRef = getDb().ref("toldya");
  const snapshot = await toldyaRef.once("value");
  const toldyas = snapshot.val();
  if (!toldyas) return { processed: 0 };

  const updates = {};
  for (const [key, tweet] of Object.entries(toldyas)) {
    if (!tweet) continue;
    if (tweet.parentkey) continue;
    if (tweet.statu !== STATU_PENDING_AI_REVIEW) continue;
    const description = tweet.description || "";
    const createdAt = tweet.createdAt || new Date().toISOString();
    const modelOrder = getModerationModelOrder();
    let lastReason = "Reddedildi";
    let approved = false;
    let result = null;

    for (const modelId of modelOrder) {
      try {
        result = await moderateWithOpenRouter(description, apiKey, modelId, createdAt);
        if (result.approved) {
          approved = true;
          console.log(`AI approved tweet ${key} with model ${modelId}, category: ${result.category}`);
          break;
        }
        lastReason = result.reason || lastReason;
        console.log(`AI rejected tweet ${key} with model ${modelId}: ${result.reason}`);
      } catch (e) {
        console.warn(`OpenRouter error for tweet ${key}, model ${modelId}:`, e.message);
        lastReason = `Hata: ${e.message}`;
      }
    }

    try {
      if (approved && result) {
        const { reason, category, endDateIso, resolutionDateIso } = result;
        updates[`toldya/${key}/statu`] = STATU_LIVE;
        updates[`toldya/${key}/aiModerationReason`] = safeString(reason) || "Onaylandı";
        updates[`toldya/${key}/topic`] = safeString(category);
        const created = new Date(createdAt);
        const defaultEnd = new Date(created.getTime() + 24 * 60 * 60 * 1000);
        const defaultRes = new Date(created.getTime() + 25 * 60 * 60 * 1000);
        let endDate = defaultEnd.toISOString();
        let resolutionDate = defaultRes.toISOString();
        if (endDateIso) {
          const d = new Date(endDateIso);
          if (!isNaN(d.getTime()) && d >= created) endDate = d.toISOString();
        }
        if (resolutionDateIso) {
          const d = new Date(resolutionDateIso);
          if (!isNaN(d.getTime()) && d >= created) resolutionDate = d.toISOString();
        }
        if (new Date(endDate) < created) {
          endDate = defaultEnd.toISOString();
          resolutionDate = defaultRes.toISOString();
        }
        if (new Date(resolutionDate) <= new Date(endDate)) {
          resolutionDate = new Date(new Date(endDate).getTime() + 60 * 60 * 1000).toISOString();
        }
        updates[`toldya/${key}/endDate`] = safeString(endDate);
        updates[`toldya/${key}/resolutionDate`] = safeString(resolutionDate);
      } else {
        updates[`toldya/${key}/statu`] = STATU_REJECTED_BY_AI;
        updates[`toldya/${key}/aiModerationReason`] = safeString(lastReason) || "Reddedildi";
        console.log(`AI rejected tweet ${key} after all models: ${lastReason}`);
      }
    } catch (e) {
      console.warn("OpenRouter error for tweet", key, e.message);
      updates[`toldya/${key}/aiModerationReason`] = safeString(`Hata: ${e.message}`);
      updates[`toldya/${key}/statu`] = STATU_REJECTED_BY_AI;
    }
  }
  if (Object.keys(updates).length > 0) {
    const safeUpdates = {};
    for (const [path, val] of Object.entries(updates)) {
      safeUpdates[path] = typeof val === "string" ? safeString(val) : val;
    }
    await getDb().ref().update(safeUpdates);
  }
  const processedCount = new Set(Object.keys(updates).map((p) => p.split("/")[1])).size;
  return { processed: processedCount };
}

/**
 * Manuel tetikleme: AI moderasyonunu çalıştırır.
 * OpenRouter key: firebase functions:secrets:set OPENROUTER_API_KEY
 * Modeller: MODERATION_MODELS listesinden rastgele biri ile başlar; red (7) gelirse sırayla diğerleri denenir.
 */
exports.runAiModeration = functions
  .runWith({ secrets: ["OPENROUTER_API_KEY"] })
  .https.onRequest(async (req, res) => {
    try {
      const apiKey = process.env.OPENROUTER_API_KEY;
      const result = await runAiModerationLogic(apiKey);
      res.status(200).json({ ok: true, ...result });
    } catch (e) {
      console.error("runAiModeration error", e);
      res.status(500).json({ ok: false, error: e.message });
    }
  });

// Zamanlanmış: Her 10 dakikada bir tüm batch fonksiyonları çalışır (manuel HTTP çağrıları da durur).
const SCHEDULE_CRON = "every 10 minutes";

/**
 * Bitiş tarihi geçmiş ve hâlâ Live (0) olan tahminleri statusLocked (5) yapar.
 */
async function runLockPredictionsLogic() {
  const toldyaRef = getDb().ref("toldya");
  const snapshot = await toldyaRef.once("value");
  const toldyas = snapshot.val();
  if (!toldyas) return { locked: 0 };

  const updates = {};
  for (const [key, tweet] of Object.entries(toldyas)) {
    if (!tweet) continue;
    if (tweet.parentkey) continue;
    if (tweet.statu !== STATU_LIVE) continue;
    const endDate = tweet.endDate;
    if (!endDate) continue;
    try {
      const end = new Date(endDate);
      if (end < new Date()) {
        updates[`toldya/${key}/statu`] = STATU_LOCKED;
      }
    } catch (e) {
      console.warn("Invalid endDate for tweet", key, e);
    }
  }
  if (Object.keys(updates).length > 0) {
    await getDb().ref().update(updates);
    console.log(`Locked ${Object.keys(updates).length} predictions`);
  }
  return { locked: Object.keys(updates).length };
}

// Logic fonksiyonları script/manuel çalıştırma için export
exports.runLockPredictionsLogic = runLockPredictionsLogic;
exports.runOracleResolutionLogic = runOracleResolutionLogic;
exports.runDistributeWinningsLogic = runDistributeWinningsLogic;
exports.runStashDripLogic = runStashDripLogic;

/** TEST: Manuel – Bitiş tarihi geçen tahminleri kilitler. (Production'da schedule'a çevrilecek.) */
exports.runLockPredictions = functions.https.onRequest(async (req, res) => {
  try {
    const result = await runLockPredictionsLogic();
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    console.error("runLockPredictions error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
});

// FeedResult değerleri (lib/helper/constant.dart ile uyumlu)
const FEED_RESULT_LIKE = 1;  // Evet
const FEED_RESULT_UNLIKE = 2;  // Hayır
const STATU_OK = 2;

/**
 * Tahmin sonuçlandırma mantığı.
 * - oracleApiUrl varsa: Harici API çağrılır, { "result": 1|2 } beklenir.
 * - oracleApiUrl yoksa: OpenRouter ile AI'dan sonuç alınır (apiKey gerekir).
 * Zorunlu: parentkey yok, statu 5 veya 1, resolutionDate geçmiş.
 */
async function runOracleResolutionLogic(apiKey, model) {
  const now = new Date();
  const toldyaRef = getDb().ref("toldya");
  const snapshot = await toldyaRef.once("value");
  const toldyas = snapshot.val();
  if (!toldyas) return { resolved: 0, skipped: [] };

  const updates = {};
  const skipped = [];
  const hasOracleUrl = (t) => t.oracleApiUrl && String(t.oracleApiUrl).trim() !== "";

  for (const [key, tweet] of Object.entries(toldyas)) {
    if (!tweet) continue;
    if (tweet.parentkey) {
      skipped.push({ key, reason: "parentkey var (yorum)" });
      continue;
    }
    if (tweet.statu !== STATU_LOCKED && tweet.statu !== 1) {
      skipped.push({ key, reason: `statu=${tweet.statu} (5 veya 1 olmalı)` });
      continue;
    }
    if (tweet.statu === STATU_OK || tweet.feedResult) {
      skipped.push({ key, reason: "zaten sonuçlanmış" });
      continue;
    }
    const resolutionDate = tweet.resolutionDate;
    if (!resolutionDate) {
      skipped.push({ key, reason: "resolutionDate yok" });
      continue;
    }
    let resDate;
    try {
      resDate = new Date(resolutionDate);
    } catch (_) {
      skipped.push({ key, reason: "resolutionDate geçersiz" });
      continue;
    }
    if (resDate > now) {
      skipped.push({ key, reason: `resolutionDate henüz geçmedi: ${resolutionDate}` });
      continue;
    }

    let result = null;
    if (hasOracleUrl(tweet)) {
      try {
        const response = await fetch(String(tweet.oracleApiUrl).trim());
        if (!response.ok) {
          skipped.push({ key, reason: `Oracle API HTTP ${response.status}` });
          continue;
        }
        const data = await response.json();
        result = data.result;
      } catch (e) {
        skipped.push({ key, reason: `Oracle hata: ${e.message}` });
        continue;
      }
    } else {
      if (!apiKey) {
        skipped.push({ key, reason: "oracleApiUrl yok ve AI için OPENROUTER_API_KEY tanımlı değil" });
        continue;
      }
      result = await resolveWithOpenRouter(
        tweet.description,
        resolutionDate,
        apiKey,
        model || MODERATION_MODELS[0]
      );
      if (result == null) {
        skipped.push({ key, reason: "AI sonuç döndürmedi (Evet/Hayır belirsiz)" });
        continue;
      }
    }

    if (result === FEED_RESULT_LIKE || result === FEED_RESULT_UNLIKE) {
      updates[`toldya/${key}/feedResult`] = result;
      updates[`toldya/${key}/statu`] = STATU_OK;
      console.log(`Oracle resolved tweet ${key} as ${result === FEED_RESULT_LIKE ? "Evet" : "Hayır"}`);
    } else {
      skipped.push({ key, reason: `sonuç geçersiz: ${JSON.stringify(result)} (1 veya 2 beklenir)` });
    }
  }
  if (Object.keys(updates).length > 0) {
    await getDb().ref().update(updates);
  }
  return {
    resolved: Object.keys(updates).length / 2,
    skipped: skipped.length > 0 ? skipped : undefined,
  };
}

/** Tahmin sonuçlandırma: oracleApiUrl varsa harici API, yoksa OpenRouter AI. OPENROUTER_API_KEY secret gerekir (AI yolu için). */
exports.runOracleResolution = functions
  .runWith({ secrets: ["OPENROUTER_API_KEY"] })
  .https.onRequest(async (req, res) => {
    try {
      const apiKey = process.env.OPENROUTER_API_KEY || null;
      const model = process.env.OPENROUTER_MODEL || null;
      const result = await runOracleResolutionLogic(apiKey, model);
      res.status(200).json({ ok: true, ...result });
    } catch (e) {
      console.error("runOracleResolution error", e);
      res.status(500).json({ ok: false, error: e.message });
    }
  });

const COMMISSION_RATE = 0.05;

// --- Tokenomics: Rütbe ve bahis limitleri (lib/helper/constant.dart ile uyumlu) ---
const XP_CAYLAK_MAX = 500;
const XP_USTA_MIN = 2000;
const RANK_MULTIPLIER_CAYLAK = 0.10;
const RANK_MULTIPLIER_TAHMINCI = 0.25;
const RANK_MULTIPLIER_USTA = 0.50;
const POOL_THRESHOLD = 1000;
const MAX_BET_SMALL_POOL = 100;
const DAILY_BONUS_AMOUNT = 500;
const STASH_PAYOUT_RATIO = 0.3;  // Kazancin %30'u stash'e
const DRIP_AMOUNT = 200;
const DRIP_INTERVAL_MS = 24 * 60 * 60 * 1000;

function sumOfVote(list) {
  if (!list || !Array.isArray(list)) return 0;
  return list.reduce((s, e) => s + (e.pegCount || 0), 0);
}

function getRankMultiplier(xp) {
  const x = xp || 0;
  if (x < XP_CAYLAK_MAX) return RANK_MULTIPLIER_CAYLAK;
  if (x < XP_USTA_MIN) return RANK_MULTIPLIER_TAHMINCI;
  return RANK_MULTIPLIER_USTA;
}

/**
 * Dağıtım mantığı: Sonuçlanmış (statu=Ok, feedResult set) ama dağıtım yapılmamış tahminler için
 * Pari-Mutuel kazanç dağıtımı.
 */
async function runDistributeWinningsLogic() {
  const db = getDb();
  const toldyaRef = db.ref("toldya");
  const profileRef = db.ref("profile");
  const snapshot = await toldyaRef.once("value");
  const toldyas = snapshot.val();
  if (!toldyas) return { distributed: 0 };

  let distributed = 0;
  for (const [key, tweet] of Object.entries(toldyas)) {
    if (!tweet) continue;
    if (tweet.parentkey) continue;
    if (tweet.distributionDone) continue;
    if (tweet.statu !== STATU_OK) continue;
    const feedResult = tweet.feedResult;
    if (feedResult !== FEED_RESULT_LIKE && feedResult !== FEED_RESULT_UNLIKE) continue;
    const winningList = feedResult === FEED_RESULT_LIKE
      ? (tweet.likeList || [])
      : (tweet.unlikeList || []);
    if (winningList.length === 0) continue;
    const totalPool = sumOfVote(tweet.likeList) + sumOfVote(tweet.unlikeList);
    if (totalPool === 0) continue;
    const distributablePool = Math.round(totalPool * (1 - COMMISSION_RATE));
    const winningTotal = sumOfVote(winningList);
    if (winningTotal === 0) continue;

    const profileUpdates = {};
    for (const el of winningList) {
      const userPeg = el.pegCount || 0;
      if (userPeg <= 0) continue;
      const payout = Math.round((userPeg / winningTotal) * distributablePool);
      const userSnap = await profileRef.child(el.userId || "").once("value");
      if (userSnap.val()) {
        const user = userSnap.val();
        const toSpendable = Math.round(payout * (1 - STASH_PAYOUT_RATIO));
        const toStash = payout - toSpendable;
        const newPeg = (user.pegCount || 0) + toSpendable;
        const newStash = (user.stashCount || 0) + toStash;
        profileUpdates[`profile/${el.userId}/pegCount`] = newPeg;
        profileUpdates[`profile/${el.userId}/stashCount`] = newStash;
      }
    }
    if (tweet.userId) {
      const predSnap = await profileRef.child(tweet.userId).once("value");
      if (predSnap.val()) {
        const pred = predSnap.val();
        profileUpdates[`profile/${tweet.userId}/predictorScore`] = (pred.predictorScore || 0) + 1;
      }
    }
    if (Object.keys(profileUpdates).length > 0) {
      profileUpdates[`toldya/${key}/distributionDone`] = true;
      await getDb().ref().update(profileUpdates);
      console.log(`Distributed winnings for tweet ${key}`);
      distributed++;
    }
  }
  return { distributed };
}

/** TEST: Manuel – Kazanç dağıtımı. (Production'da schedule'a çevrilecek.) */
exports.runDistributeWinnings = functions.https.onRequest(async (req, res) => {
  try {
    const result = await runDistributeWinningsLogic();
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    console.error("runDistributeWinnings error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
});

// --- Callable: placeBet – Bahis tek noktadan, limit ve bakiye kontrolü ---
// enforceAppCheck: false → App Check zorunluluğu kapalı (cihaz/GMS hatası geçene kadar)
exports.placeBet = functions.runWith({ enforceAppCheck: false }).https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Oturum açmanız gerekir.");
    }
    const userId = safeString(context.auth.uid).trim() || context.auth.uid;
    const rawToldyaId = data?.toldyaId ?? data?.tweetId;
    const toldyaId = safeString(String(rawToldyaId || "")).trim() || rawToldyaId;
    const side = data?.side;
    const amount = typeof data?.amount === "number" ? Math.floor(data.amount) : parseInt(data?.amount, 10);

    if (!toldyaId || (side !== FEED_RESULT_LIKE && side !== FEED_RESULT_UNLIKE) || !Number.isInteger(amount) || amount <= 0) {
      throw new functions.https.HttpsError("invalid-argument", "Geçersiz bahis miktarı veya parametre.");
    }

    const tweetSnap = await getDb().ref(`toldya/${toldyaId}`).once("value");
    const tweet = tweetSnap.val();
    if (!tweet || tweet.parentkey) {
      throw new functions.https.HttpsError("not-found", "Tahmin bulunamadı.");
    }
    if (tweet.statu !== STATU_LIVE) {
      throw new functions.https.HttpsError("failed-precondition", "Bu tahmine artık bahis kapatıldı.");
    }

    // Bir tahminde kullanıcı yalnızca tek tarafa (Evet veya Hayır) bahis yapabilir
    const likeList = Array.isArray(tweet.likeList) ? tweet.likeList : [];
    const unlikeList = Array.isArray(tweet.unlikeList) ? tweet.unlikeList : [];
    const inLike = likeList.some((e) => (e && (e.userId || e)) === userId);
    const inUnlike = unlikeList.some((e) => (e && (e.userId || e)) === userId);
    if (side === FEED_RESULT_LIKE && inUnlike) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Bu tahminde zaten Hayır tarafında bahis yaptınız. Bir tahminde yalnızca tek tarafa bahis yapabilirsiniz."
      );
    }
    if (side === FEED_RESULT_UNLIKE && inLike) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Bu tahminde zaten Evet tarafında bahis yaptınız. Bir tahminde yalnızca tek tarafa bahis yapabilirsiniz."
      );
    }

    const profileSnap = await getDb().ref(`profile/${userId}`).once("value");
    const profile = profileSnap.val();
    if (!profile) {
      throw new functions.https.HttpsError("not-found", "Profil bulunamadı.");
    }

    const spendableBalance = profile.pegCount || 0;
    const xp = profile.xp || 0;
    const rankMultiplier = getRankMultiplier(xp);
    const maxBetByRank = Math.floor(spendableBalance * rankMultiplier);

    if (amount > maxBetByRank) {
      const pct = Math.round(rankMultiplier * 100);
      throw new functions.https.HttpsError(
        "resource-exhausted",
        `En fazla bakiyenizin %${pct}'ini yatırabilirsiniz.`
      );
    }
    if (amount > spendableBalance) {
      throw new functions.https.HttpsError("resource-exhausted", "Yetersiz bakiye.");
    }

    const totalPool = sumOfVote(tweet.likeList) + sumOfVote(tweet.unlikeList);
    const maxBetForPool = totalPool < POOL_THRESHOLD ? MAX_BET_SMALL_POOL : Number.MAX_SAFE_INTEGER;
    if (amount > maxBetForPool) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        `Havuz henüz küçük, maksimum ${MAX_BET_SMALL_POOL} token yatırılabilir.`
      );
    }

    const listKey = side === FEED_RESULT_LIKE ? "likeList" : "unlikeList";
    const countKey = side === FEED_RESULT_LIKE ? "likeCount" : "unlikeCount";
    const rawList = Array.isArray(tweet[listKey]) ? tweet[listKey].slice() : [];
    const list = rawList.map((e) => ({ userId: safeString(e.userId || e || "").trim() || String(e.userId || e), pegCount: e.pegCount || 0 }));
    const idx = list.findIndex((e) => e.userId === userId);
    const newPeg = (idx >= 0 ? list[idx].pegCount : 0) + amount;
    if (idx >= 0) {
      list[idx] = { userId: safeString(userId).trim() || userId, pegCount: newPeg };
    } else {
      list.push({ userId: safeString(userId).trim() || userId, pegCount: newPeg });
    }

    const newBalance = spendableBalance - amount;
    const notifUserId = safeString(tweet.userId || "").trim() || "unknown";
    const updates = {
      [`profile/${userId}/pegCount`]: newBalance,
      [`toldya/${toldyaId}/${listKey}`]: list,
    };
    const likeCount = side === FEED_RESULT_LIKE ? (tweet.likeCount || 0) + (idx >= 0 ? 0 : 1) : (tweet.likeCount || 0);
    const unlikeCount = side === FEED_RESULT_UNLIKE ? (tweet.unlikeCount || 0) + (idx >= 0 ? 0 : 1) : (tweet.unlikeCount || 0);
    if (listKey === "likeList") updates[`toldya/${toldyaId}/likeCount`] = likeCount;
    else updates[`toldya/${toldyaId}/unlikeCount`] = unlikeCount;

    // Bildirim: sadece başkası bahis yaptığında yaz (sahip kendi tahminine bahis yapınca bildirim gitmesin)
    if (userId !== notifUserId) {
      updates[`notification/${notifUserId}/${toldyaId}`] = {
        type: side === FEED_RESULT_LIKE ? "NotificationType.Like" : "NotificationType.UnLike",
        updatedAt: new Date().toISOString(),
      };
    }

    const safeUpdates = {};
    for (const [path, val] of Object.entries(updates)) {
      const cleanPath = safeString(String(path)).trim() || path;
      safeUpdates[cleanPath] = deepSanitize(val);
    }
    await getDb().ref().update(safeUpdates);

    const newStashBalance = profile.stashCount || 0;
    return {
      ok: true,
      newBalance,
      newStashBalance,
      message: "Bahis kabul edildi.",
    };
  } catch (err) {
    if (err instanceof functions.https.HttpsError) throw err;
    console.error("placeBet error:", err);
    throw new functions.https.HttpsError("internal", err.message || "Bahis işlenirken hata oluştu.");
  }
});

// --- Callable: claimDailyBonus – Günlük giriş bonusu ---
exports.claimDailyBonus = functions.runWith({ enforceAppCheck: false }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Oturum açmanız gerekir.");
  }
  const userId = context.auth.uid;
  const profileSnap = await getDb().ref(`profile/${userId}`).once("value");
  const profile = profileSnap.val();
  if (!profile) {
    throw new functions.https.HttpsError("not-found", "Profil bulunamadı.");
  }

  const now = new Date();
  const lastClaim = profile.lastDailyClaimAt ? new Date(profile.lastDailyClaimAt) : null;
  const sameDay = lastClaim &&
    lastClaim.getUTCFullYear() === now.getUTCFullYear() &&
    lastClaim.getUTCMonth() === now.getUTCMonth() &&
    lastClaim.getUTCDate() === now.getUTCDate();

  if (sameDay) {
    throw new functions.https.HttpsError(
      "resource-exhausted",
      "Bugünkü bonusu zaten aldınız."
    );
  }

  const currentPeg = profile.pegCount || 0;
  const newPeg = currentPeg + DAILY_BONUS_AMOUNT;
  const updates = {
    [`profile/${userId}/pegCount`]: newPeg,
    [`profile/${userId}/lastDailyClaimAt`]: now.toISOString(),
  };
  await getDb().ref().update(updates);

  return {
    ok: true,
    newBalance: newPeg,
    message: `Günlük bonus: +${DAILY_BONUS_AMOUNT} token.`,
  };
});

// --- Stash Drip: Kademeli Cüzdan Sistemi ---
// 
// AMAÇ: Kullanıcının bakiyesi sıfıra indiğinde oyundan kopmamasını sağlamak.
// 
// NASIL ÇALIŞIR:
// 1. Kazançların bir kısmı (%30) "stashCount" (kilitli bakiye) olarak saklanır.
// 2. Kullanıcının harcanabilir bakiyesi (pegCount) sıfıra indiğinde:
//    - Her 24 saatte bir, stash'ten 200 token (veya stash'te kalan miktar, hangisi azsa)
//      otomatik olarak harcanabilir bakiyeye aktarılır.
// 3. Bu sayede kullanıcı "Param bitti ama yarın yine gelecek" hissini yaşar.
//
// ÖRNEK SENARYO:
// - Kullanıcı 1000 token kazandı → 700 token pegCount'a, 300 token stashCount'a gider.
// - Kullanıcı tüm 700 token'ı bahislerde kaybetti → pegCount = 0, stashCount = 300.
// - 24 saat sonra runStashDrip çalıştırıldığında:
//   → pegCount = 200 (stash'ten aktarıldı)
//   → stashCount = 100 (kalan)
//   → lastStashDripAt = şimdiki zaman (bir sonraki drip için zaman damgası)
// - Kullanıcı tekrar bahis yapabilir!
// - 24 saat sonra tekrar çalıştırıldığında:
//   → pegCount = 100 (stash'te kalan son 100 token)
//   → stashCount = 0
//   → lastStashDripAt güncellenir
//
// KOŞULLAR:
// - Sadece pegCount === 0 ve stashCount > 0 olan kullanıcılar için çalışır.
// - Son drip'ten en az 24 saat geçmiş olmalı (DRIP_INTERVAL_MS = 24 saat).
// - Her seferinde maksimum 200 token aktarılır (DRIP_AMOUNT).
// - Eğer stash'te 200'den az varsa, tümü aktarılır.
//
// TETİKLEME:
// - Şu an sadece MANUEL olarak HTTP isteği ile tetiklenir.
// - URL: https://[region]-[project].cloudfunctions.net/runStashDrip
// - Production'da istenirse zamanlanmış (scheduled) fonksiyona çevrilebilir.
//
async function runStashDripLogic() {
  const profileRef = getDb().ref("profile");
  const snapshot = await profileRef.once("value");
  const profiles = snapshot.val();
  if (!profiles) return { dripped: 0 };

  const now = Date.now();
  const updates = {};
  let processedCount = 0;

  for (const [uid, profile] of Object.entries(profiles)) {
    if (!profile) continue;
    
    // Koşul 1: Harcanabilir bakiye tamamen sıfır olmalı
    const peg = profile.pegCount || 0;
    if (peg !== 0) continue;
    
    // Koşul 2: Kilitli bakiyede token olmalı
    const stash = profile.stashCount || 0;
    if (stash <= 0) continue;

    // Koşul 3: Son drip'ten en az 24 saat geçmiş olmalı
    const lastDrip = profile.lastStashDripAt ? new Date(profile.lastStashDripAt).getTime() : 0;
    const timeSinceLastDrip = now - lastDrip;
    if (timeSinceLastDrip < DRIP_INTERVAL_MS) {
      // Henüz 24 saat geçmemiş, bu kullanıcıyı atla
      continue;
    }

    // Aktarım miktarını hesapla: stash'te kalan veya 200 token, hangisi azsa
    const dripAmount = Math.min(DRIP_AMOUNT, stash);
    
    // Veritabanı güncellemelerini hazırla
    updates[`profile/${uid}/pegCount`] = dripAmount;  // Harcanabilir bakiyeye ekle
    updates[`profile/${uid}/stashCount`] = stash - dripAmount;  // Stash'ten düş
    updates[`profile/${uid}/lastStashDripAt`] = new Date().toISOString();  // Zaman damgası
    
    processedCount++;
  }

  // Tüm güncellemeleri atomik olarak uygula
  if (Object.keys(updates).length > 0) {
    await getDb().ref().update(updates);
    console.log(`Stash drip tamamlandı: ${processedCount} kullanıcıya token aktarıldı.`);
  }

  return { dripped: processedCount };
}

/**
 * MANUEL TETİKLEME: Stash sızdırma işlemini çalıştırır.
 * 
 * KULLANIM:
 * - HTTP GET veya POST ile çağrılır.
 * - URL: https://[region]-[project].cloudfunctions.net/runStashDrip
 * - Yanıt: { "ok": true, "dripped": 5 } (5 kullanıcıya token aktarıldı)
 * 
 * NOT: Bu fonksiyon sadece manuel tetikleme için tasarlanmıştır.
 * Otomatik zamanlanmış çalışma için production'da schedule eklenebilir.
 */
exports.runStashDrip = functions.https.onRequest(async (req, res) => {
  try {
    const result = await runStashDripLogic();
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    console.error("runStashDrip error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
});

// --- Zamanlanmış: Her 10 dakikada bir çalışan sürümler ---
exports.scheduledAiModeration = functions
  .runWith({ secrets: ["OPENROUTER_API_KEY"] })
  .pubsub.schedule(SCHEDULE_CRON)
  .onRun(async () => {
    try {
      const apiKey = process.env.OPENROUTER_API_KEY;
      const result = await runAiModerationLogic(apiKey);
      console.log("[scheduledAiModeration] done", result);
    } catch (e) {
      console.error("[scheduledAiModeration] error", e);
    }
  });

exports.scheduledLockPredictions = functions.pubsub
  .schedule(SCHEDULE_CRON)
  .onRun(async () => {
    try {
      const result = await runLockPredictionsLogic();
      console.log("[scheduledLockPredictions] done", result);
    } catch (e) {
      console.error("[scheduledLockPredictions] error", e);
    }
  });

exports.scheduledOracleResolution = functions
  .runWith({ secrets: ["OPENROUTER_API_KEY"] })
  .pubsub.schedule(SCHEDULE_CRON)
  .onRun(async () => {
    try {
      const apiKey = process.env.OPENROUTER_API_KEY || null;
      const model = process.env.OPENROUTER_MODEL || null;
      const result = await runOracleResolutionLogic(apiKey, model);
      console.log("[scheduledOracleResolution] done", result);
    } catch (e) {
      console.error("[scheduledOracleResolution] error", e);
    }
  });

exports.scheduledDistributeWinnings = functions.pubsub
  .schedule(SCHEDULE_CRON)
  .onRun(async () => {
    try {
      const result = await runDistributeWinningsLogic();
      console.log("[scheduledDistributeWinnings] done", result);
    } catch (e) {
      console.error("[scheduledDistributeWinnings] error", e);
    }
  });

exports.scheduledStashDrip = functions.pubsub
  .schedule(SCHEDULE_CRON)
  .onRun(async () => {
    try {
      const result = await runStashDripLogic();
      console.log("[scheduledStashDrip] done", result);
    } catch (e) {
      console.error("[scheduledStashDrip] error", e);
    }
  });

// --- FCM Bildirim (Realtime Database Triggers) - notifications.js ---
const notifications = require("./notifications");
exports.onPredictionResolved = notifications.onPredictionResolved;
exports.onBetCreated = notifications.onBetCreated;
exports.onFollowerCreated = notifications.onFollowerCreated;
