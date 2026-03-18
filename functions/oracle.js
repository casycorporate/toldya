const { getDb, safeString, STATU_LOCKED, STATU_OK, FEED_RESULT_LIKE, FEED_RESULT_UNLIKE } = require("./shared");
const log = require("./logger");

const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";

const RESOLUTION_SYSTEM_PROMPT = `Sen bir tahmin sonuçlandırma asistanısın. Verilen tahmin metnini ve sonuçlanma zamanını dikkate alarak, tahminin GERÇEKLEŞİP GERÇEKLEŞMEDİĞİNE karar ver.
Evet/Hayır ile cevaplanabilir bir tahmin (örn. "Yarın yağmur yağacak mı?") için, bilinen gerçeklere veya makul çıkarıma göre yanıt ver.
Yanıtını SADECE şu JSON formatında ver, başka metin yazma: {"sonuc": 1} veya {"sonuc": 2}
- 1 = Evet (tahmin doğru çıktı)
- 2 = Hayır (tahmin yanlış çıktı veya gerçekleşmedi)`;

async function resolveWithOpenRouter(description, resolutionDate, apiKey, model) {
  if (!apiKey) return null;
  const cleanKey = safeString(apiKey).replace(/\s/g, "").trim() || apiKey;
  const userContent = `Tahmin: ${safeString(description) || "(yok)"}\nSonuçlanma zamanı: ${safeString(resolutionDate) || ""}\nBu tahmin gerçekleşti mi? Sadece JSON ver: {"sonuc": 1} veya {"sonuc": 2}`;
  const res = await fetch(OPENROUTER_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: `Bearer ${cleanKey}` },
    body: JSON.stringify({
      model: safeString(model) || "google/gemini-3-flash-preview",
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
      result = await resolveWithOpenRouter(tweet.description, resolutionDate, apiKey, model);
      if (result == null) {
        skipped.push({ key, reason: "AI sonuç döndürmedi (Evet/Hayır belirsiz)" });
        continue;
      }
    }

    if (result === FEED_RESULT_LIKE || result === FEED_RESULT_UNLIKE) {
      updates[`toldya/${key}/feedResult`] = result;
      updates[`toldya/${key}/statu`] = STATU_OK;
    } else {
      skipped.push({ key, reason: `sonuç geçersiz: ${JSON.stringify(result)} (1 veya 2 beklenir)` });
    }
  }

  if (Object.keys(updates).length > 0) {
    await getDb().ref().update(updates);
  }
  const resolvedCount = Object.keys(updates).length / 2;
  log.info("[oracle] resolved", { resolved: resolvedCount, skipped: skipped.length });
  return { resolved: resolvedCount, skipped: skipped.length > 0 ? skipped : undefined };
}

module.exports = { runOracleResolutionLogic };

