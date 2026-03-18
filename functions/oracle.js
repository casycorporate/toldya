const { getDb, safeString, STATU_LOCKED, STATU_OK, FEED_RESULT_LIKE, FEED_RESULT_UNLIKE } = require("./shared");
const log = require("./logger");

// Bu dosya artık yalnızca harici oracleApiUrl üzerinden sonuçlandırma yapar.

async function runOracleResolutionLogic() {
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
    if (!hasOracleUrl(tweet)) {
      skipped.push({ key, reason: "oracleApiUrl yok" });
      continue;
    }

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

