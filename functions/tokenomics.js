const {
  getDb,
  sumOfVote,
  STATU_OK,
  FEED_RESULT_LIKE,
  FEED_RESULT_UNLIKE,
  COMMISSION_RATE,
  STASH_PAYOUT_RATIO,
  STREAK_MIN,
  STREAK_MULTIPLIER,
  DRIP_AMOUNT,
  DRIP_INTERVAL_MS,
} = require("./shared");
const log = require("./logger");

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
    const likeList = tweet.likeList || [];
    const unlikeList = tweet.unlikeList || [];
    const winningList = feedResult === FEED_RESULT_LIKE ? likeList : unlikeList;
    const losingList = feedResult === FEED_RESULT_LIKE ? unlikeList : likeList;

    const totalPool = sumOfVote(likeList) + sumOfVote(unlikeList);
    const distributablePool = Math.round(totalPool * (1 - COMMISSION_RATE));
    const winningTotal = sumOfVote(winningList);

    const profileUpdates = {};

    // Winners boşsa payout yapmıyoruz, ama losing streak + distributionDone'u yine set ediyoruz.
    if (winningTotal > 0) {
      for (const el of winningList) {
        const userPeg = el.pegCount || 0;
        if (userPeg <= 0) continue;
        const payout = Math.round((userPeg / winningTotal) * distributablePool);
        const userId = (el.userId || "").trim();
        if (!userId) continue;
        const userSnap = await profileRef.child(userId).once("value");
        if (userSnap.val()) {
          const user = userSnap.val();
          const currentStreak = user.currentStreak != null ? user.currentStreak : 0;
          const newStreak = currentStreak + 1;
          const multiplier = newStreak >= STREAK_MIN ? STREAK_MULTIPLIER : 1.0;
          const multipliedPayout = Math.round(payout * multiplier);
          const toSpendable = Math.round(multipliedPayout * (1 - STASH_PAYOUT_RATIO));
          const toStash = multipliedPayout - toSpendable;
          const newPeg = (user.pegCount || 0) + toSpendable;
          const newStash = (user.stashCount || 0) + toStash;
          profileUpdates[`profile/${userId}/pegCount`] = newPeg;
          profileUpdates[`profile/${userId}/stashCount`] = newStash;
          profileUpdates[`profile/${userId}/currentStreak`] = newStreak;
          profileUpdates[`profile/${userId}/lastStreakUpdatedAt`] = new Date().toISOString();
        }
      }
    }

    for (const el of losingList) {
      const uid = el && (el.userId != null ? el.userId : el);
      if (uid) {
        profileUpdates[`profile/${uid}/currentStreak`] = 0;
        profileUpdates[`profile/${uid}/lastStreakUpdatedAt`] = new Date().toISOString();
      }
    }
    if (tweet.userId) {
      const predSnap = await profileRef.child(tweet.userId).once("value");
      if (predSnap.val()) {
        const pred = predSnap.val();
        profileUpdates[`profile/${tweet.userId}/predictorScore`] = (pred.predictorScore || 0) + 1;
      }
    }
    profileUpdates[`toldya/${key}/distributionDone`] = true;
    await db.ref().update(profileUpdates);
    distributed++;
  }
  log.info("[tokenomics] distributeWinnings done", { distributed });
  return { distributed };
}

async function distributeWinningsForToldyaIdLogic(toldyaId) {
  const key = String(toldyaId || "").trim();
  if (!key) return { distributed: 0, reason: "missing_toldyaId" };

  const db = getDb();
  const toldyaRef = db.ref(`toldya/${key}`);
  const profileRef = db.ref("profile");

  const snap = await toldyaRef.once("value");
  const tweet = snap.val();
  if (!tweet) return { distributed: 0, reason: "not_found" };
  if (tweet.parentkey) return { distributed: 0, reason: "is_reply" };
  if (tweet.distributionDone) return { distributed: 0, reason: "already_done" };
  if (tweet.statu !== STATU_OK) return { distributed: 0, reason: "wrong_statu" };
  const feedResult = tweet.feedResult;
  if (feedResult !== FEED_RESULT_LIKE && feedResult !== FEED_RESULT_UNLIKE) return { distributed: 0, reason: "wrong_result" };

  const likeList = tweet.likeList || [];
  const unlikeList = tweet.unlikeList || [];
  const winningList = feedResult === FEED_RESULT_LIKE ? likeList : unlikeList;
  const losingList = feedResult === FEED_RESULT_LIKE ? unlikeList : likeList;

  const totalPool = sumOfVote(likeList) + sumOfVote(unlikeList);
  const distributablePool = Math.round(totalPool * (1 - COMMISSION_RATE));
  const winningTotal = sumOfVote(winningList);

  const profileUpdates = {};

  if (winningTotal > 0) {
    for (const el of winningList) {
      const userPeg = el.pegCount || 0;
      if (userPeg <= 0) continue;
      const payout = Math.round((userPeg / winningTotal) * distributablePool);
      const userId = (el.userId || "").trim();
      if (!userId) continue;
      const userSnap = await profileRef.child(userId).once("value");
      if (userSnap.val()) {
        const user = userSnap.val();
        const currentStreak = user.currentStreak != null ? user.currentStreak : 0;
        const newStreak = currentStreak + 1;
        const multiplier = newStreak >= STREAK_MIN ? STREAK_MULTIPLIER : 1.0;
        const multipliedPayout = Math.round(payout * multiplier);
        const toSpendable = Math.round(multipliedPayout * (1 - STASH_PAYOUT_RATIO));
        const toStash = multipliedPayout - toSpendable;
        const newPeg = (user.pegCount || 0) + toSpendable;
        const newStash = (user.stashCount || 0) + toStash;
        profileUpdates[`profile/${userId}/pegCount`] = newPeg;
        profileUpdates[`profile/${userId}/stashCount`] = newStash;
        profileUpdates[`profile/${userId}/currentStreak`] = newStreak;
        profileUpdates[`profile/${userId}/lastStreakUpdatedAt`] = new Date().toISOString();
      }
    }
  }

  for (const el of losingList) {
    const uid = el && (el.userId != null ? el.userId : el);
    const userId = uid != null ? String(uid).trim() : "";
    if (userId) {
      profileUpdates[`profile/${userId}/currentStreak`] = 0;
      profileUpdates[`profile/${userId}/lastStreakUpdatedAt`] = new Date().toISOString();
    }
  }
  if (tweet.userId) {
    const predSnap = await profileRef.child(tweet.userId).once("value");
    if (predSnap.val()) {
      const pred = predSnap.val();
      profileUpdates[`profile/${tweet.userId}/predictorScore`] = (pred.predictorScore || 0) + 1;
    }
  }

  profileUpdates[`toldya/${key}/distributionDone`] = true;
  await db.ref().update(profileUpdates);
  log.info("[tokenomics] distributeWinnings one", { key, totalPool, distributablePool });
  return { distributed: 1 };
}

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
    const peg = profile.pegCount || 0;
    if (peg !== 0) continue;
    const stash = profile.stashCount || 0;
    if (stash <= 0) continue;

    const lastDrip = profile.lastStashDripAt ? new Date(profile.lastStashDripAt).getTime() : 0;
    const timeSinceLastDrip = now - lastDrip;
    if (timeSinceLastDrip < DRIP_INTERVAL_MS) continue;

    const dripAmount = Math.min(DRIP_AMOUNT, stash);
    updates[`profile/${uid}/pegCount`] = dripAmount;
    updates[`profile/${uid}/stashCount`] = stash - dripAmount;
    updates[`profile/${uid}/lastStashDripAt`] = new Date().toISOString();
    processedCount++;
  }

  if (Object.keys(updates).length > 0) {
    await getDb().ref().update(updates);
  }
  log.info("[tokenomics] stashDrip done", { dripped: processedCount });
  return { dripped: processedCount };
}

module.exports = { runDistributeWinningsLogic, distributeWinningsForToldyaIdLogic, runStashDripLogic };

