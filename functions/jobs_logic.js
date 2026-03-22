const { getDb, STATU_LIVE, STATU_LOCKED } = require("./shared");
const log = require("./logger");

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
      log.warn("[lockPredictions] invalid endDate", { key, endDate });
    }
  }

  if (Object.keys(updates).length > 0) {
    await getDb().ref().update(updates);
  }
  return { locked: Object.keys(updates).length };
}

module.exports = { runLockPredictionsLogic };

