const log = require("./logger");
const {
  getDb,
  admin,
  safeString,
  deepSanitize,
  sumOfVote,
  getRankMultiplier,
  STATU_LIVE,
  STATU_LOCKED,
  STATU_OK,
  STATU_PENDING_AI_REVIEW,
  STATU_REJECTED_BY_AI,
  FEED_RESULT_LIKE,
  FEED_RESULT_UNLIKE,
  POOL_THRESHOLD,
  MAX_BET_SMALL_POOL,
  DAILY_BONUS_AMOUNT,
} = require("./shared");
const { distributeWinningsForToldyaIdLogic } = require("./tokenomics");

function registerCallables(functions) {
  // enforceAppCheck: false → App Check zorunluluğu kapalı (cihaz/GMS hatası geçene kadar)
  const placeBet = functions.runWith({ enforceAppCheck: false }).https.onCall(async (data, context) => {
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

      // Bir tahminde kullanıcı yalnızca tek tarafa bahis yapabilir
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
      // TEMP: Aggressive max bet cap = 75% of spendable balance.
      // (Rank/pool limits are intentionally disabled for now; can be re-enabled later.)
      const maxBet = Math.floor(spendableBalance * 0.75);
      if (amount > maxBet) {
        throw new functions.https.HttpsError(
          "resource-exhausted",
          `En fazla bakiyenizin %75'ini yatırabilirsiniz. (Maks: ${maxBet})`
        );
      }
      if (amount > spendableBalance) {
        throw new functions.https.HttpsError("resource-exhausted", "Yetersiz bakiye.");
      }

      // Pool-size based cap temporarily disabled.

      const listKey = side === FEED_RESULT_LIKE ? "likeList" : "unlikeList";
      const rawList = Array.isArray(tweet[listKey]) ? tweet[listKey].slice() : [];
      const list = rawList.map((e) => ({ userId: safeString(e.userId || e || "").trim() || String(e.userId || e), pegCount: e.pegCount || 0 }));
      const idx = list.findIndex((e) => e.userId === userId);
      const newPeg = (idx >= 0 ? list[idx].pegCount : 0) + amount;
      if (idx >= 0) list[idx] = { userId: safeString(userId).trim() || userId, pegCount: newPeg };
      else list.push({ userId: safeString(userId).trim() || userId, pegCount: newPeg });

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

      // Bildirim: sadece başkası bahis yaptığında yaz
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
      return { ok: true, newBalance, newStashBalance, message: "Bahis kabul edildi." };
    } catch (err) {
      if (err instanceof functions.https.HttpsError) throw err;
      log.error("placeBet error", err);
      throw new functions.https.HttpsError("internal", err.message || "Bahis işlenirken hata oluştu.");
    }
  });

  const voteReply = functions.runWith({ enforceAppCheck: false }).https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Oturum açmanız gerekir.");
    }
    const userId = safeString(context.auth.uid).trim() || context.auth.uid;
    const rawToldyaId = data?.toldyaId;
    const toldyaId = safeString(String(rawToldyaId || "")).trim() || rawToldyaId;
    const vote = data?.vote;
    if (!toldyaId || (vote !== 1 && vote !== -1)) {
      throw new functions.https.HttpsError("invalid-argument", "Geçersiz toldyaId veya vote (1 veya -1).");
    }

    const snap = await getDb().ref(`toldya/${toldyaId}`).once("value");
    const tweet = snap.val();
    if (!tweet || !tweet.parentkey) {
      throw new functions.https.HttpsError("failed-precondition", "Bu yalnızca yorum (reply) için kullanılır.");
    }

    const upvoteUserIds = Array.isArray(tweet.upvoteUserIds) ? [...tweet.upvoteUserIds] : [];
    const downvoteUserIds = Array.isArray(tweet.downvoteUserIds) ? [...tweet.downvoteUserIds] : [];
    let upvoteCount = typeof tweet.upvoteCount === "number" ? tweet.upvoteCount : 0;
    let downvoteCount = typeof tweet.downvoteCount === "number" ? tweet.downvoteCount : 0;

    if (upvoteUserIds.includes(userId)) {
      upvoteUserIds.splice(upvoteUserIds.indexOf(userId), 1);
      upvoteCount = Math.max(0, upvoteCount - 1);
    }
    if (downvoteUserIds.includes(userId)) {
      downvoteUserIds.splice(downvoteUserIds.indexOf(userId), 1);
      downvoteCount = Math.max(0, downvoteCount - 1);
    }

    if (vote === 1) {
      upvoteUserIds.push(userId);
      upvoteCount += 1;
    } else {
      downvoteUserIds.push(userId);
      downvoteCount += 1;
    }

    await getDb().ref(`toldya/${toldyaId}`).update({ upvoteCount, downvoteCount, upvoteUserIds, downvoteUserIds });
    return { ok: true, upvoteCount, downvoteCount, upvoteUserIds, downvoteUserIds };
  });

  const claimDailyBonus = functions.runWith({ enforceAppCheck: false }).https.onCall(async (data, context) => {
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
      throw new functions.https.HttpsError("resource-exhausted", "Bugünkü bonusu zaten aldınız.");
    }

    const currentPeg = profile.pegCount || 0;
    const newPeg = currentPeg + DAILY_BONUS_AMOUNT;
    const updates = {
      [`profile/${userId}/pegCount`]: newPeg,
      [`profile/${userId}/lastDailyClaimAt`]: now.toISOString(),
    };
    await getDb().ref().update(updates);

    return { ok: true, newBalance: newPeg, message: `Günlük bonus: +${DAILY_BONUS_AMOUNT} token.` };
  });

  // --- Callable: deleteAccount – Kullanıcı hesabını güvenli şekilde sil ---
  // Store requirement: Risky/destructive action must be real + auth-protected.
  const deleteAccount = functions.runWith({ enforceAppCheck: false }).https.onCall(async (data, context) => {
    try {
      if (!context?.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Oturum açmanız gerekir.");
      }

      const uid = safeString(context.auth.uid).trim() || context.auth.uid;
      if (!uid) {
        throw new functions.https.HttpsError("invalid-argument", "Geçersiz uid.");
      }

      const db = getDb();
      const updates = {};

      // Delete user-owned RTDB data first.
      updates[`profile/${uid}`] = null;
      updates[`notification/${uid}`] = null;
      // follower entries where this uid is the followedUserId
      updates[`followers/${uid}`] = null;

      // Delete toldya content owned by this user.
      // Schema (see functions/NOTIFICATIONS_README.md):
      // toldya/{toldyaId} → { ..., userId: sahibin uid }
      const toldyaSnap = await db.ref("toldya").orderByChild("userId").equalTo(uid).once("value");
      if (toldyaSnap?.exists()) {
        const toldyaIds = [];
        toldyaSnap.forEach((child) => {
          if (child?.key) toldyaIds.push(child.key);
        });

        for (const toldyaId of toldyaIds) {
          updates[`toldya/${toldyaId}`] = null;
          // Best-effort: remove moderation/audit logs stored per toldyaId.
          updates[`moderationLogs/${toldyaId}`] = null;
        }
      }

      // Apply all RTDB deletions in one update call.
      await db.ref().update(updates);

      // Delete Firebase Auth user last (server-side admin).
      await admin.auth().deleteUser(uid);

      return { ok: true };
    } catch (err) {
      if (err instanceof functions.https.HttpsError) throw err;
      // Best-effort: provide a deterministic error code.
      const message = err?.message || "Hesap silinirken hata oluştu.";
      throw new functions.https.HttpsError("internal", message);
    }
  });

  // --- Admin moderation: Manual approve/reject for statu=6 ---
  const moderateToldya = functions.runWith({ enforceAppCheck: false }).https.onCall(async (data, context) => {
    const reqId = safeString(String(context?.rawRequest?.headers?.["x-cloud-trace-context"] || "")).split("/")[0] || "";
    let _stage = "init";
    const stageLog = (stage, meta = {}) => {
      _stage = stage;
      // Debug-only: keep prod logs clean
      log.debug("[moderateToldya]", deepSanitize({ stage, reqId, ...meta }));
    };

    try {

      stageLog("start", { hasAuth: !!context.auth });
      if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Oturum açmanız gerekir.");
      }
      const uid = safeString(context.auth.uid).trim() || context.auth.uid;
      stageLog("auth_ok", { uid });

      // Temporary admin authorization: RTDB `profile/{uid}/isAdmin == true`
      let isAdmin = false;
      try {
        const adminSnap = await getDb().ref(`profile/${uid}/isAdmin`).once("value");
        const v = adminSnap.val();
        isAdmin = v === true || v === 1 || v === "true";
      } catch (_) {}
      if (!isAdmin) {
        stageLog("deny_not_admin", {});
        throw new functions.https.HttpsError("permission-denied", "Yetkisiz işlem.");
      }
      stageLog("admin_ok", {});

      const rawId = data?.toldyaId ?? data?.postId ?? data?.id;
      const toldyaId = safeString(String(rawId || "")).trim();
      if (!toldyaId) {
        stageLog("bad_input_no_toldyaId", { rawId: String(rawId || "") });
        throw new functions.https.HttpsError("invalid-argument", "toldyaId zorunludur.");
      }

      const decisionRaw = safeString(String(data?.decision || "")).trim().toLowerCase();
      const decision = decisionRaw === "approve" ? "approve" : (decisionRaw === "reject" ? "reject" : "");
      if (!decision) {
        stageLog("bad_input_decision", { decisionRaw });
        throw new functions.https.HttpsError("invalid-argument", "decision approve|reject olmalı.");
      }
      stageLog("input_ok", { toldyaId, decision });

    const reasonRaw = data?.reason;
    const reason = reasonRaw == null ? "" : safeString(String(reasonRaw)).trim();
    if (decision === "reject") {
      if (!reason) throw new functions.https.HttpsError("invalid-argument", "reject için reason zorunludur.");
      if (reason.length < 5) throw new functions.https.HttpsError("invalid-argument", "reason en az 5 karakter olmalı.");
    }

    const topicInput = data?.topic != null ? safeString(String(data.topic)).trim() : "";
    const endDateInput = data?.endDate != null ? safeString(String(data.endDate)).trim() : "";
    const resolutionDateInput = data?.resolutionDate != null ? safeString(String(data.resolutionDate)).trim() : "";
    const oracleSourceInput = data?.oracleSource != null ? safeString(String(data.oracleSource)).trim() : "";
    const oracleApiUrlInput = data?.oracleApiUrl != null ? safeString(String(data.oracleApiUrl)).trim() : "";
    const collateralAmountInput = data?.collateralAmount;
    // Debug-only visibility (stageLog is debug-gated)
    stageLog("payload_flags", {
      hasTopicInput: !!topicInput,
      hasEndDateInput: !!endDateInput,
      hasResolutionDateInput: !!resolutionDateInput,
    });

    const allowedTopics = new Set(["spor", "eco", "fun", "politic"]);
    function parseIsoUtc(str, fieldName) {
      if (!str) return null;
      const d = new Date(str);
      if (isNaN(d.getTime())) throw new functions.https.HttpsError("invalid-argument", `${fieldName} geçersiz (ISO olmalı).`);
      return d;
    }

    const toldyaRef = getDb().ref(`toldya/${toldyaId}`);
    const at = new Date().toISOString();

    // Pre-read to compute/validate final approve fields (backend is single source of truth).
    let pre = null;
    try {
      const snap = await toldyaRef.once("value");
      pre = snap.val();
    } catch (_) {}

    if (!pre) throw new functions.https.HttpsError("not-found", "Tahmin bulunamadı.");
    if (pre.parentkey) throw new functions.https.HttpsError("failed-precondition", "Yorum moderasyonu desteklenmiyor.");
    stageLog("pre_read_ok", {
      statu: pre.statu,
      hasManual: !!pre.manualModerationAt,
      hasTopic: !!pre.topic,
      hasEndDate: !!pre.endDate,
      hasResolutionDate: !!pre.resolutionDate,
    });
    const preStatuNum = Number(pre.statu);

    let approveFinal = null;
    if (decision === "approve") {
      const finalTopic = (topicInput || safeString(String(pre.topic || "")).trim()).toLowerCase();
      const finalEndDateRaw = endDateInput || safeString(String(pre.endDate || "")).trim();
      const finalResolutionDateRaw = resolutionDateInput || safeString(String(pre.resolutionDate || "")).trim();

      if (!finalTopic || !finalEndDateRaw || !finalResolutionDateRaw) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "MISSING_REQUIRED_FIELDS",
          { missing: { topic: !finalTopic, endDate: !finalEndDateRaw, resolutionDate: !finalResolutionDateRaw } }
        );
      }
      if (!allowedTopics.has(finalTopic)) {
        throw new functions.https.HttpsError("failed-precondition", "INVALID_TOPIC");
      }

      const now = new Date();
      const endD = parseIsoUtc(finalEndDateRaw, "endDate");
      const resD = parseIsoUtc(finalResolutionDateRaw, "resolutionDate");
      if (endD <= now) throw new functions.https.HttpsError("failed-precondition", "endDate gelecekte olmalı.");
      if (resD <= now) throw new functions.https.HttpsError("failed-precondition", "resolutionDate gelecekte olmalı.");
      if (resD <= endD) throw new functions.https.HttpsError("failed-precondition", "resolutionDate endDate'ten sonra olmalı.");
      const minGapMs = 60 * 60 * 1000;
      if ((resD.getTime() - endD.getTime()) < minGapMs) {
        throw new functions.https.HttpsError("failed-precondition", "resolutionDate endDate'ten en az 1 saat sonra olmalı.");
      }

      let collateralAmount = null;
      if (collateralAmountInput != null) {
        const n = Number(collateralAmountInput);
        if (!Number.isFinite(n) || n < 0) {
          throw new functions.https.HttpsError("invalid-argument", "collateralAmount geçersiz.");
        }
        collateralAmount = n;
      }

      approveFinal = {
        topic: finalTopic,
        endDate: endD.toISOString(),
        resolutionDate: resD.toISOString(),
        oracleSource: oracleSourceInput || null,
        oracleApiUrl: oracleApiUrlInput || null,
        collateralAmount,
      };
    }

    // Concurrency-safe update without full-node transaction:
    // 1) Atomically change statu from 6 -> 0/7 (less contention than entire toldya node)
    // 2) Then update remaining fields (manualModerationAt/by/decision + required fields)
    const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
    const maxTxAttempts = 12;
    const jitter = () => Math.floor(Math.random() * 101); // 0-100ms

    const targetStatu = decision === "approve" ? STATU_LIVE : STATU_REJECTED_BY_AI;
    const statuRef = getDb().ref(`toldya/${toldyaId}/statu`);

    let committed = false;
    let lastStatuSeen = null;
    for (let attempt = 1; attempt <= maxTxAttempts; attempt++) {
      const tx = await statuRef.transaction((cur) => {
        lastStatuSeen = cur;
        // If child `statu` is temporarily missing but parent snapshot says it's pending,
        // treat it as pending to self-heal missing child field.
        const n = (cur == null && preStatuNum === STATU_PENDING_AI_REVIEW) ? STATU_PENDING_AI_REVIEW : Number(cur);
        if (n !== STATU_PENDING_AI_REVIEW) return; // abort
        return targetStatu;
      }, undefined, false);

      if (tx?.committed) {
        committed = true;
        stageLog("statu_tx_committed", { attempt, from: STATU_PENDING_AI_REVIEW, to: targetStatu });
        break;
      }

      // If not committed and still looks pending (rare), retry with backoff.
      const n = Number(lastStatuSeen);
      if (n !== STATU_PENDING_AI_REVIEW) {
        stageLog("statu_tx_abort_wrong_statu", { attempt, statu: lastStatuSeen, expected: STATU_PENDING_AI_REVIEW });
        break;
      }
      const backoffMs = Math.min(150 * attempt, 1200) + jitter();
      stageLog("statu_tx_retry", { attempt, backoffMs });
      await sleep(backoffMs);
    }

    if (!committed) {
      // Best-effort read for richer error
      const snap = await toldyaRef.once("value");
      const cur = snap.val();
      if (!cur) throw new functions.https.HttpsError("not-found", "Tahmin bulunamadı.");
      if (cur.parentkey) throw new functions.https.HttpsError("failed-precondition", "Yorum moderasyonu desteklenmiyor.");
      if (cur.manualModerationAt) {
        stageLog("already_moderated", { manualModerationAt: cur.manualModerationAt, manualModerationBy: cur.manualModerationBy || "" });
        throw new functions.https.HttpsError(
          "already-exists",
          "Zaten moderasyon yapılmış.",
          { manualModerationAt: cur.manualModerationAt, manualModerationBy: cur.manualModerationBy || "" }
        );
      }
      const statuNum = Number(cur.statu);
      if (statuNum !== STATU_PENDING_AI_REVIEW) {
        stageLog("wrong_statu", { statu: cur.statu, expected: STATU_PENDING_AI_REVIEW });
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Bu kayıt bekleyen durumda değil.",
          { statu: cur.statu, expected: STATU_PENDING_AI_REVIEW }
        );
      }
      stageLog("statu_tx_not_committed_race", {});
      throw new functions.https.HttpsError(
        "aborted",
        "CONCURRENT_UPDATE_RETRY",
        { toldyaId, hint: "race-condition", canRetry: true }
      );
    }

    // Apply remaining fields (merge update; should not conflict with other writers).
    const updates = {
      manualModerationAt: at,
      manualModerationBy: uid,
      manualModerationDecision: decision,
      manualModerationReason: reason || "",
    };
    if (decision === "approve") {
      updates.topic = approveFinal.topic;
      updates.endDate = approveFinal.endDate;
      updates.resolutionDate = approveFinal.resolutionDate;
      if (approveFinal.oracleSource) updates.oracleSource = approveFinal.oracleSource;
      if (approveFinal.oracleApiUrl) updates.oracleApiUrl = approveFinal.oracleApiUrl;
      if (approveFinal.collateralAmount != null) updates.collateralAmount = approveFinal.collateralAmount;
    }
    await toldyaRef.update(updates);

    const appliedDecision = decision;
    const finalSnapshotForClient = {
      statu: targetStatu,
      topic: updates.topic || "",
      endDate: updates.endDate || "",
      resolutionDate: updates.resolutionDate || "",
    };
    stageLog("update_done", { decision: appliedDecision });
      // Append-only audit log
      try {
        const logRef = getDb().ref(`moderationLogs/${toldyaId}`).push();
        await logRef.set(deepSanitize({
          by: uid,
          at,
          decision,
          reason: reason || "",
          source: "admin",
        }));
      } catch (e) {
        // Do not fail moderation; audit is best-effort but important to log.
        log.warn("moderationLogs write failed", { toldyaId, message: e.message });
      }

      stageLog("done", {});
      return { ok: true, decision: appliedDecision, toldya: finalSnapshotForClient };
    } catch (e) {
      // Log exact thrown error (HttpsError or unexpected) with last stage.
      const code = e?.code || e?.details?.code || "";
      const message = e?.message || "";
      const details = e?.details || e?.metadata || null;
      log.error("[moderateToldya]", deepSanitize({ stage: "error", lastStage: _stage, reqId, code, message, details }));
      throw e;
    }
  });

  async function _requireAdmin(uid) {
    let isAdmin = false;
    try {
      const adminSnap = await getDb().ref(`profile/${uid}/isAdmin`).once("value");
      const v = adminSnap.val();
      isAdmin = v === true || v === 1 || v === "true";
    } catch (_) {}
    if (!isAdmin) throw new functions.https.HttpsError("permission-denied", "Yetkisiz işlem.");
  }

  const adminResolveToldya = functions.runWith({ enforceAppCheck: false }).https.onCall(async (data, context) => {
    if (!context?.auth) throw new functions.https.HttpsError("unauthenticated", "Oturum açmanız gerekir.");
    const uid = safeString(context.auth.uid).trim() || context.auth.uid;
    await _requireAdmin(uid);

    const rawId = data?.toldyaId ?? data?.postId ?? data?.id;
    const toldyaId = safeString(String(rawId || "")).trim();
    if (!toldyaId) throw new functions.https.HttpsError("invalid-argument", "toldyaId zorunludur.");

    const resultRaw = data?.feedResult ?? data?.result;
    const feedResult = Number(resultRaw);
    if (feedResult !== FEED_RESULT_LIKE && feedResult !== FEED_RESULT_UNLIKE) {
      throw new functions.https.HttpsError("invalid-argument", "feedResult 1|2 olmalı.");
    }

    const toldyaRef = getDb().ref(`toldya/${toldyaId}`);
    const snap = await toldyaRef.once("value");
    const cur = snap.val();
    if (!cur) throw new functions.https.HttpsError("not-found", "Tahmin bulunamadı.");
    if (cur.parentkey) throw new functions.https.HttpsError("failed-precondition", "Yorum sonuçlandırma desteklenmiyor.");
    if (cur.feedResult != null) throw new functions.https.HttpsError("already-exists", "Zaten sonuçlandırılmış.");

    const statu = Number(cur.statu);
    if (statu !== STATU_LOCKED && statu !== 1 && statu !== STATU_OK) {
      throw new functions.https.HttpsError("failed-precondition", "Tahmin sonuçlandırma için uygun değil.");
    }

    const nowIso = new Date().toISOString();
    await toldyaRef.update(deepSanitize({
      feedResult,
      statu: STATU_OK,
      resolutionSource: "manual_admin",
      resolutionBy: uid,
      resolvedAt: nowIso,
    }));

    return { ok: true, toldyaId, feedResult, statu: STATU_OK };
  });

  const adminDistributeWinningsForToldya = functions.runWith({ enforceAppCheck: false }).https.onCall(async (data, context) => {
    if (!context?.auth) throw new functions.https.HttpsError("unauthenticated", "Oturum açmanız gerekir.");
    const uid = safeString(context.auth.uid).trim() || context.auth.uid;
    await _requireAdmin(uid);

    const rawId = data?.toldyaId ?? data?.postId ?? data?.id;
    const toldyaId = safeString(String(rawId || "")).trim();
    if (!toldyaId) throw new functions.https.HttpsError("invalid-argument", "toldyaId zorunludur.");

    const result = await distributeWinningsForToldyaIdLogic(toldyaId);
    return { ok: true, toldyaId, ...deepSanitize(result) };
  });

  return { placeBet, voteReply, claimDailyBonus, deleteAccount, moderateToldya, adminResolveToldya, adminDistributeWinningsForToldya };
}

module.exports = { registerCallables };

