const { getDb, safeString, STATU_LIVE, STATU_PENDING_AI_REVIEW, STATU_REJECTED_BY_AI } = require("./shared");
const log = require("./logger");

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

async function moderateWithOpenRouter(description, apiKey, model, referenceDateIso) {
  const cleanKey = safeString(apiKey).replace(/\s/g, "").trim() || apiKey;
  const refDate = referenceDateIso ? new Date(referenceDateIso) : new Date();
  const refIso = referenceDateIso && !isNaN(refDate.getTime())
    ? refDate.toISOString().slice(0, 10)
    : refDate.toISOString().slice(0, 10);
  const userContent =
    (safeString(description) || "(metin yok)") +
    `\n\n[ÖNEMLİ: Referans tarih (kayıt anı): ${refIso}. endDate ve resolutionDate MUTLAKA bu tarihten SONRA olmalı. Örn. "Nisan ay sonu" dersen ${refDate.getFullYear()}-04-30 kullan, geçmiş yıl kullanma.]`;
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
    headers: { "Content-Type": "application/json", Authorization: `Bearer ${cleanKey}` },
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
    const gerekceStr =
      rawGerekce != null && String(rawGerekce).trim() !== "" ? String(rawGerekce).trim() : "";
    const reason = onay
      ? safeString(gerekceStr) || "Uygun"
      : safeString(gerekceStr) ||
        "Red nedeni AI tarafindan yazilmadi. Olasi nedenler: topluluk kurallari (nefret/hakaret), tahmin Evet/Hayir ile sonuclanamiyor, belirsiz veya kategori uygun degil.";
    let endDateIso = null;
    let resolutionDateIso = null;
    if (onay) {
      const rawEnd = parsed.endDate;
      const rawRes = parsed.resolutionDate;
      if (rawEnd != null && String(rawEnd).trim() !== "") endDateIso = String(rawEnd).trim();
      if (rawRes != null && String(rawRes).trim() !== "") resolutionDateIso = String(rawRes).trim();
    }
    return { approved: onay, reason, category, endDateIso: endDateIso || null, resolutionDateIso: resolutionDateIso || null };
  } catch (e) {
    const lower = content.toLowerCase();
    const approved = lower.includes("\"onay\": true") || (lower.includes("evet") && !lower.includes("hayır"));
    return { approved, reason: "Yanıt ayrıştırılamadı", category: "spor", endDateIso: null, resolutionDateIso: null };
  }
}

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
  let processedCount = 0;
  for (const [key, tweet] of Object.entries(toldyas)) {
    if (!tweet) continue;
    if (tweet.statu !== STATU_PENDING_AI_REVIEW) continue;
    // If admin already moderated, AI must never touch again.
    if (tweet.manualModerationAt) continue;
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
          log.debug("[moderation] approved", { key, modelId, category: result.category });
          break;
        }
        lastReason = result.reason || lastReason;
        log.debug("[moderation] rejected", { key, modelId });
      } catch (e) {
        log.warn("[moderation] openrouter error", { key, modelId, message: e.message });
        lastReason = `Hata: ${e.message}`;
      }
    }

    try {
      if (approved && result) {
        const { reason, category, endDateIso, resolutionDateIso } = result;
        const isReply = !!tweet.parentkey;
        updates[`toldya/${key}/statu`] = STATU_LIVE;
        updates[`toldya/${key}/aiModerationReason`] = safeString(reason) || "Onaylandı";
        if (category) updates[`toldya/${key}/topic`] = safeString(category);
        if (!isReply) {
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
        }
      } else {
        updates[`toldya/${key}/statu`] = STATU_REJECTED_BY_AI;
        updates[`toldya/${key}/aiModerationReason`] = safeString(lastReason) || "Reddedildi";
      }
      processedCount++;
    } catch (e) {
      log.warn("[moderation] update build error", { key, message: e.message });
      updates[`toldya/${key}/aiModerationReason`] = safeString(`Hata: ${e.message}`);
      updates[`toldya/${key}/statu`] = STATU_REJECTED_BY_AI;
      processedCount++;
    }
  }

  if (Object.keys(updates).length > 0) {
    const safeUpdates = {};
    for (const [path, val] of Object.entries(updates)) {
      safeUpdates[path] = typeof val === "string" ? safeString(val) : val;
    }
    await getDb().ref().update(safeUpdates);
  }
  return { processed: processedCount };
}

module.exports = { runAiModerationLogic };

