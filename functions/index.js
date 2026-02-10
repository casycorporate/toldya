const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.database();

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
const OPENROUTER_DEFAULT_MODEL = "openai/gpt-4o-mini";

const MODERATION_SYSTEM_PROMPT = `Sen bir sosyal tahmin platformu moderatörüsün. Verilen metni şu kriterlere göre değerlendir:
1) Topluluk kurallarına uygun mu? (nefret, hakaret, yasadışı içerik yok)
2) Net ve tutarlı bir tahmin mi? (Evet/Hayır ile sonuçlanabilir, belirsiz veya anlamsız değil)

Yanıtını SADECE şu JSON formatında ver, başka metin yazma:
{"onay": true veya false, "gerekce": "kısa açıklama"}`;

/**
 * OpenRouter API ile tek bir gönderi metnini moderasyon kontrolünden geçirir.
 * @param {string} description - Gönderi metni
 * @param {string} apiKey - OpenRouter API key
 * @param {string} model - Model ID (örn. openai/gpt-4o-mini)
 * @returns {{ approved: boolean, reason?: string }}
 */
async function moderateWithOpenRouter(description, apiKey, model) {
  const res = await fetch(OPENROUTER_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: model || OPENROUTER_DEFAULT_MODEL,
      messages: [
        { role: "system", content: MODERATION_SYSTEM_PROMPT },
        { role: "user", content: description || "(metin yok)" },
      ],
      max_tokens: 200,
      temperature: 0.2,
    }),
  });
  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`OpenRouter ${res.status}: ${errText}`);
  }
  const data = await res.json();
  const content = data.choices?.[0]?.message?.content?.trim() || "";
  try {
    const jsonMatch = content.match(/\{[\s\S]*\}/);
    const parsed = jsonMatch ? JSON.parse(jsonMatch[0]) : {};
    const onay = parsed.onay === true;
    return { approved: onay, reason: parsed.gerekce || (onay ? "Uygun" : "Uygun değil") };
  } catch (e) {
    const lower = content.toLowerCase();
    const approved = lower.includes("\"onay\": true") || (lower.includes("evet") && !lower.includes("hayır"));
    return { approved, reason: "Yanıt ayrıştırılamadı" };
  }
}

/**
 * AI moderasyon mantığını çalıştırır (statu=6 → 0 veya 7).
 * apiKey ve model, Secret Manager + runWith({ secrets }) ile process.env üzerinden gelir.
 */
async function runAiModerationLogic(apiKey, model) {
  if (!apiKey) {
    throw new Error(
      "OpenRouter API key tanımlı değil. Ayarlayın: firebase functions:secrets:set OPENROUTER_API_KEY"
    );
  }
  const effectiveModel = model || OPENROUTER_DEFAULT_MODEL;

  const tweetRef = db.ref("tweet");
  const snapshot = await tweetRef.once("value");
  const tweets = snapshot.val();
  if (!tweets) return { processed: 0 };

  const updates = {};
  for (const [key, tweet] of Object.entries(tweets)) {
    if (!tweet) continue;
    if (tweet.parentkey) continue;
    if (tweet.statu !== STATU_PENDING_AI_REVIEW) continue;
    const description = tweet.description || "";
    try {
      const { approved, reason } = await moderateWithOpenRouter(description, apiKey, effectiveModel);
      if (approved) {
        updates[`tweet/${key}/statu`] = STATU_LIVE;
        updates[`tweet/${key}/aiModerationReason`] = reason || "Onaylandı";
        console.log(`AI approved tweet ${key}`);
      } else {
        updates[`tweet/${key}/statu`] = STATU_REJECTED_BY_AI;
        updates[`tweet/${key}/aiModerationReason`] = reason || "Reddedildi";
        console.log(`AI rejected tweet ${key}: ${reason}`);
      }
    } catch (e) {
      console.warn("OpenRouter error for tweet", key, e.message);
      updates[`tweet/${key}/aiModerationReason`] = `Hata: ${e.message}`;
      updates[`tweet/${key}/statu`] = STATU_REJECTED_BY_AI;
    }
  }
  if (Object.keys(updates).length > 0) {
    await db.ref().update(updates);
  }
  return { processed: Object.keys(updates).length / 2 };
}

/**
 * Manuel tetikleme: AI moderasyonunu çalıştırır.
 * OpenRouter key: firebase functions:secrets:set OPENROUTER_API_KEY
 * Model (opsiyonel): .env içinde OPENROUTER_MODEL veya varsayılan openai/gpt-4o-mini
 */
exports.runAiModeration = functions
  .runWith({ secrets: ["OPENROUTER_API_KEY"] })
  .https.onRequest(async (req, res) => {
    try {
      const apiKey = process.env.OPENROUTER_API_KEY;
      const model = process.env.OPENROUTER_MODEL;
      const result = await runAiModerationLogic(apiKey, model);
      res.status(200).json({ ok: true, ...result });
    } catch (e) {
      console.error("runAiModeration error", e);
      res.status(500).json({ ok: false, error: e.message });
    }
  });

// TEST AŞAMASI: Tüm işler manuel (HTTP). Schedule yok.
// Production'da schedule açmak için zamanlanmış sürümler tekrar eklenir.

/**
 * Bitiş tarihi geçmiş ve hâlâ Live (0) olan tahminleri statusLocked (5) yapar.
 */
async function runLockPredictionsLogic() {
  const tweetRef = db.ref("tweet");
  const snapshot = await tweetRef.once("value");
  const tweets = snapshot.val();
  if (!tweets) return { locked: 0 };

  const updates = {};
  for (const [key, tweet] of Object.entries(tweets)) {
    if (!tweet) continue;
    if (tweet.parentkey) continue;
    if (tweet.statu !== STATU_LIVE) continue;
    const endDate = tweet.endDate;
    if (!endDate) continue;
    try {
      const end = new Date(endDate);
      if (end < new Date()) {
        updates[`tweet/${key}/statu`] = STATU_LOCKED;
      }
    } catch (e) {
      console.warn("Invalid endDate for tweet", key, e);
    }
  }
  if (Object.keys(updates).length > 0) {
    await db.ref().update(updates);
    console.log(`Locked ${Object.keys(updates).length} predictions`);
  }
  return { locked: Object.keys(updates).length };
}

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
 * Tahmin sonuçlandırma mantığı: oracleApiUrl + resolutionDate geçmiş kayıtlar için API çağrısı.
 * API yanıtı: { "result": 1 } = Evet, { "result": 2 } = Hayır
 */
async function runOracleResolutionLogic() {
  const now = new Date();
  const tweetRef = db.ref("tweet");
  const snapshot = await tweetRef.once("value");
  const tweets = snapshot.val();
  if (!tweets) return { resolved: 0 };

  const updates = {};
  for (const [key, tweet] of Object.entries(tweets)) {
    if (!tweet) continue;
    if (tweet.parentkey) continue;
    if (!tweet.oracleApiUrl || tweet.oracleApiUrl.trim() === "") continue;
    if (tweet.statu === STATU_OK || tweet.feedResult) continue;
    if (tweet.statu !== STATU_LOCKED && tweet.statu !== 1) continue;
    const resolutionDate = tweet.resolutionDate;
    if (!resolutionDate) continue;
    try {
      const resDate = new Date(resolutionDate);
      if (resDate > now) continue;
      const response = await fetch(tweet.oracleApiUrl.trim());
      if (!response.ok) {
        console.warn("Oracle API failed for tweet", key, response.status);
        continue;
      }
      const data = await response.json();
      const result = data.result;
      if (result === FEED_RESULT_LIKE || result === FEED_RESULT_UNLIKE) {
        updates[`tweet/${key}/feedResult`] = result;
        updates[`tweet/${key}/statu`] = STATU_OK;
        console.log(`Oracle resolved tweet ${key} as ${result === FEED_RESULT_LIKE ? "Evet" : "Hayır"}`);
      }
    } catch (e) {
      console.warn("Oracle error for tweet", key, e.message);
    }
  }
  if (Object.keys(updates).length > 0) {
    await db.ref().update(updates);
  }
  return { resolved: Object.keys(updates).length / 2 };
}

/** TEST: Manuel – Oracle ile tahmin sonuçlandırma. (Production'da schedule'a çevrilecek.) */
exports.runOracleResolution = functions.https.onRequest(async (req, res) => {
  try {
    const result = await runOracleResolutionLogic();
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
  const tweetRef = db.ref("tweet");
  const profileRef = db.ref("profile");
  const snapshot = await tweetRef.once("value");
  const tweets = snapshot.val();
  if (!tweets) return { distributed: 0 };

  let distributed = 0;
  for (const [key, tweet] of Object.entries(tweets)) {
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
      profileUpdates[`tweet/${key}/distributionDone`] = true;
      await db.ref().update(profileUpdates);
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
exports.placeBet = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Oturum açmanız gerekir.");
  }
  const userId = context.auth.uid;
  const tweetId = data?.tweetId;
  const side = data?.side;
  const amount = typeof data?.amount === "number" ? Math.floor(data.amount) : parseInt(data?.amount, 10);

  if (!tweetId || (side !== FEED_RESULT_LIKE && side !== FEED_RESULT_UNLIKE) || !Number.isInteger(amount) || amount <= 0) {
    throw new functions.https.HttpsError("invalid-argument", "Geçersiz bahis miktarı veya parametre.");
  }

  const tweetSnap = await db.ref(`tweet/${tweetId}`).once("value");
  const tweet = tweetSnap.val();
  if (!tweet || tweet.parentkey) {
    throw new functions.https.HttpsError("not-found", "Tahmin bulunamadı.");
  }
  if (tweet.statu !== STATU_LIVE) {
    throw new functions.https.HttpsError("failed-precondition", "Bu tahmine artık bahis kapatıldı.");
  }

  const profileSnap = await db.ref(`profile/${userId}`).once("value");
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
  const list = Array.isArray(tweet[listKey]) ? tweet[listKey].slice() : [];
  const idx = list.findIndex((e) => (e.userId || e) === userId);
  const newPeg = (idx >= 0 ? (list[idx].pegCount || 0) : 0) + amount;
  if (idx >= 0) {
    list[idx] = { ...list[idx], userId: list[idx].userId || userId, pegCount: newPeg };
  } else {
    list.push({ userId, pegCount: newPeg });
  }

  const newBalance = spendableBalance - amount;
  const updates = {
    [`profile/${userId}/pegCount`]: newBalance,
    [`tweet/${tweetId}/${listKey}`]: list,
  };
  const likeCount = side === FEED_RESULT_LIKE ? (tweet.likeCount || 0) + (idx >= 0 ? 0 : 1) : (tweet.likeCount || 0);
  const unlikeCount = side === FEED_RESULT_UNLIKE ? (tweet.unlikeCount || 0) + (idx >= 0 ? 0 : 1) : (tweet.unlikeCount || 0);
  if (listKey === "likeList") updates[`tweet/${tweetId}/likeCount`] = likeCount;
  else updates[`tweet/${tweetId}/unlikeCount`] = unlikeCount;

  updates[`notification/${tweet.userId || ""}/${tweetId}`] = {
    type: side === FEED_RESULT_LIKE ? "NotificationType.Like" : "NotificationType.UnLike",
    updatedAt: new Date().toISOString(),
  };

  await db.ref().update(updates);

  const newStashBalance = profile.stashCount || 0;
  return {
    ok: true,
    newBalance,
    newStashBalance,
    message: "Bahis kabul edildi.",
  };
});

// --- Callable: claimDailyBonus – Günlük giriş bonusu ---
exports.claimDailyBonus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Oturum açmanız gerekir.");
  }
  const userId = context.auth.uid;
  const profileSnap = await db.ref(`profile/${userId}`).once("value");
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
  await db.ref().update(updates);

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
  const profileRef = db.ref("profile");
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
    await db.ref().update(updates);
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
