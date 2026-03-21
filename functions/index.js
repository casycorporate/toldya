const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { onRequestJob } = require("./jobs");
const log = require("./logger");

// Logic is being moved to modules; keep exports stable.
const { runLockPredictionsLogic: runLockPredictionsLogicModule } = require("./jobs_logic");
const { runOracleResolutionLogic: runOracleResolutionLogicModule } = require("./oracle");
const { runDistributeWinningsLogic: runDistributeWinningsLogicModule, runStashDripLogic: runStashDripLogicModule } = require("./tokenomics");
const { runLeagueAssignmentLogic: runLeagueAssignmentLogicModule, runWeeklyLeagueResetLogic: runWeeklyLeagueResetLogicModule } = require("./leagues");
const { registerCallables } = require("./callables");

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

// --- TEST AŞAMASI: Tüm işler MANUEL (HTTP). Üç ayrı sorumluluk ---
// 1) Kilit:          runLockPredictions        → endDate geçen Live tahminleri statu=5 (Locked)
// 2) Sonuçlandırma:  runOracleResolution       → oracle API ile feedResult + statu=Ok
// 3) Dağıtım:        runDistributeWinnings    → sonuçlanmış tahminlerde kazanç payı

// Statu değerleri (lib/helper/constant.dart ile uyumlu)
const STATU_LIVE = 0;
const STATU_LOCKED = 5;

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

// AI moderasyon bu sürümde devre dışı bırakıldı; yalnızca manuel admin moderasyonu kullanılır.

// Zamanlanmış: Her 30 dakikada bir tüm batch fonksiyonları çalışır (manuel HTTP çağrıları da durur).
const SCHEDULE_CRON = "every 30 minutes";

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
      log.warn("Invalid endDate for tweet", { key, endDate: tweet.endDate });
    }
  }
  if (Object.keys(updates).length > 0) {
    await getDb().ref().update(updates);
    log.info("Locked predictions", { locked: Object.keys(updates).length });
  }
  return { locked: Object.keys(updates).length };
}

// --- Weekly Leagues (Haftalık Lig): tier, weeklyXp, yükselme/düşme ---
// Tier eşikleri (toplam xp): 0–500 Bronze, 501–1500 Silver, 1501–3500 Gold, 3501+ Diamond
const LEAGUE_GROUP_SIZE = 30;
const LEAGUE_TIER_NAMES_OLD = ["Bronz", "Gümüş", "Altın"];
const LEAGUE_TIERS = ["Bronze", "Silver", "Gold", "Diamond"];
const XP_BRONZE_MAX = 500;
const XP_SILVER_MAX = 1500;
const XP_GOLD_MAX = 3500;

function getTierFromXp(xp) {
  const x = typeof xp === "number" ? xp : (parseInt(xp, 10) || 0);
  if (x <= XP_BRONZE_MAX) return "Bronze";
  if (x <= XP_SILVER_MAX) return "Silver";
  if (x <= XP_GOLD_MAX) return "Gold";
  return "Diamond";
}

/** ISO hafta kimliği (örn. "2025-W06") */
function getISOWeekId(date) {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() + 4 - (d.getDay() || 7));
  const yearStart = new Date(d.getFullYear(), 0, 1);
  const weekNo = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
  return d.getFullYear() + "-W" + String(weekNo).padStart(2, "0");
}

/** Verilen weekId'nin Pazar 23:59 UTC bitiş tarihi (ISO string). */
function getWeekEndISO(weekId) {
  const m = weekId.match(/^(\d{4})-W(\d{2})$/);
  if (!m) return null;
  const y = parseInt(m[1], 10);
  const w = parseInt(m[2], 10);
  const jan4 = new Date(Date.UTC(y, 0, 4));
  const day = jan4.getUTCDay();
  const mondayWeek1 = new Date(Date.UTC(y, 0, 4 - (day === 0 ? 6 : day - 1)));
  const mondayWeekW = new Date(mondayWeek1);
  mondayWeekW.setUTCDate(mondayWeek1.getUTCDate() + (w - 1) * 7);
  const sunday = new Date(mondayWeekW);
  sunday.setUTCDate(mondayWeekW.getUTCDate() + 6);
  sunday.setUTCHours(23, 59, 0, 0);
  return sunday.toISOString();
}

/** Tarihten sonraki haftanın weekId'si. */
function getNextWeekId(date) {
  const d = new Date(date);
  d.setDate(d.getDate() + 7);
  return getISOWeekId(d);
}

/**
 * Tüm profilleri XP'ye göre sıralar, gruplara böler; leagues/weeks/{weekId}/groups ve profile'a leagueWeekId/leagueGroupId yazar.
 * Mevcut leaderboard (rank, predictorScore) değiştirilmez.
 */
async function runLeagueAssignmentLogic() {
  const db = getDb();
  const profileRef = db.ref("profile");
  const snapshot = await profileRef.once("value");
  const profiles = snapshot.val();
  if (!profiles || typeof profiles !== "object") {
    return { weekId: null, groups: 0, usersAssigned: 0 };
  }

  const weekId = getISOWeekId(new Date());
  const configRef = db.ref("leagues/config");
  await configRef.set({
    groupSize: LEAGUE_GROUP_SIZE,
    tierNames: LEAGUE_TIER_NAMES,
    currentWeekId: weekId,
  });

  const entries = [];
  for (const [userId, p] of Object.entries(profiles)) {
    if (!p || typeof p !== "object") continue;
    const xp = typeof p.xp === "number" ? p.xp : (parseInt(p.xp, 10) || 0);
    entries.push({ userId: String(userId), xp });
  }
  entries.sort((a, b) => b.xp - a.xp);

  const groups = {};
  const profileUpdates = {};
  for (let i = 0; i < entries.length; i++) {
    const groupId = Math.floor(i / LEAGUE_GROUP_SIZE);
    const { userId, xp } = entries[i];
    if (!groups[groupId]) groups[groupId] = {};
    groups[groupId][userId] = xp;
    profileUpdates[`profile/${userId}/leagueWeekId`] = weekId;
    profileUpdates[`profile/${userId}/leagueGroupId`] = String(groupId);
  }

  const weekRef = db.ref(`leagues/weeks/${weekId}/groups`);
  await weekRef.set(groups);
  if (Object.keys(profileUpdates).length > 0) {
    await db.ref().update(profileUpdates);
  }
  const groupCount = Object.keys(groups).length;
  log.info("[runLeagueAssignment]", { weekId, groups: groupCount, users: entries.length });
  return { weekId, groups: groupCount, usersAssigned: entries.length };
}

/** Manuel tetikleme: Haftalık lig ataması. */
exports.runLeagueAssignment = onRequestJob(async (req, res) => {
  try {
    const result = await runLeagueAssignmentLogicModule();
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    log.error("runLeagueAssignment error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
}, { secrets: ["JOBS_SHARED_SECRET"] });

/**
 * Haftalık lig sıfırlama: Tüm weeklyXp=0, sonraki hafta için tier bazlı 30’luk gruplar atar.
 * Mevcut hafta grupları varsa üst 5 yükselir, alt 5 düşer; yoksa tier = getTierFromXp(xp).
 * leagues/config: currentWeekId, weekEndsAt (Pazar 23:59 UTC), tierNames, groupSize.
 */
async function runWeeklyLeagueResetLogic() {
  const db = getDb();
  const profileRef = db.ref("profile");
  const snapshot = await profileRef.once("value");
  const profiles = snapshot.val();
  if (!profiles || typeof profiles !== "object") {
    return { weekId: null, groups: 0, usersAssigned: 0 };
  }

  const now = new Date();
  const currentWeekId = getISOWeekId(now);
  const nextWeekId = getNextWeekId(now);

  // 1) Tüm profillerde weeklyXp = 0
  const zeroUpdates = {};
  for (const uid of Object.keys(profiles)) {
    zeroUpdates[`profile/${uid}/weeklyXp`] = 0;
  }
  if (Object.keys(zeroUpdates).length > 0) {
    await db.ref().update(zeroUpdates);
  }

  // 2) Mevcut hafta gruplarını oku; her kullanıcı için sonraki tier hesapla (üst 5 yükselir, alt 5 düşer)
  const userIdToNextTier = {};
  const weekRef = db.ref(`leagues/weeks/${currentWeekId}/groups`);
  const weekSnap = await weekRef.once("value");
  const currentGroups = weekSnap.val();

  if (currentGroups && typeof currentGroups === "object") {
    for (const [, groupMap] of Object.entries(currentGroups)) {
      if (!groupMap || typeof groupMap !== "object") continue;
      const entries = Object.entries(groupMap).map(([uid, xp]) => ({
        userId: uid,
        xp: typeof xp === "number" ? xp : (parseInt(xp, 10) || 0),
      }));
      entries.sort((a, b) => b.xp - a.xp);
      const tierIdx = (tier) => {
        const i = LEAGUE_TIERS.indexOf(tier);
        return i >= 0 ? i : 0;
      };
      for (let r = 0; r < entries.length; r++) {
        const rank = r + 1;
        const userId = entries[r].userId;
        const p = profiles[userId];
        const currentTier = (p && p.tier) ? String(p.tier) : getTierFromXp(p?.xp);
        const idx = tierIdx(currentTier);
        if (rank <= 5) {
          userIdToNextTier[userId] = LEAGUE_TIERS[Math.min(idx + 1, LEAGUE_TIERS.length - 1)];
        } else if (rank >= 26) {
          userIdToNextTier[userId] = LEAGUE_TIERS[Math.max(idx - 1, 0)];
        } else {
          userIdToNextTier[userId] = currentTier;
        }
      }
    }
  }

  // Mevcut hafta grubu yoksa veya listede olmayan kullanıcılar: tier = xp’ten
  for (const [userId, p] of Object.entries(profiles)) {
    if (!p || typeof p !== "object") continue;
    if (!userIdToNextTier[userId]) {
      userIdToNextTier[userId] = getTierFromXp(p.xp);
    }
  }

  // 3) Tier’a göre topla, karıştır, 30’luk gruplara böl
  const byTier = {};
  for (const tier of LEAGUE_TIERS) byTier[tier] = [];
  for (const [uid, tier] of Object.entries(userIdToNextTier)) {
    if (byTier[tier]) byTier[tier].push(uid);
  }

  const groups = {};
  const profileUpdates = {};
  for (const tier of LEAGUE_TIERS) {
    const list = byTier[tier] || [];
    for (let i = 0; i < list.length; i++) {
      const j = Math.floor(Math.random() * (i + 1));
      [list[i], list[j]] = [list[j], list[i]];
    }
    let groupIndex = 0;
    for (let i = 0; i < list.length; i += LEAGUE_GROUP_SIZE) {
      const chunk = list.slice(i, i + LEAGUE_GROUP_SIZE);
      const groupKey = `${tier}_${groupIndex}`;
      const groupData = {};
      for (const uid of chunk) groupData[uid] = 0;
      groups[groupKey] = groupData;
      for (const uid of chunk) {
        profileUpdates[`profile/${uid}/leagueWeekId`] = nextWeekId;
        profileUpdates[`profile/${uid}/leagueGroupId`] = groupKey;
        profileUpdates[`profile/${uid}/tier`] = tier;
      }
      groupIndex++;
    }
  }

  const weekWriteRef = db.ref(`leagues/weeks/${nextWeekId}/groups`);
  await weekWriteRef.set(groups);

  const batchSize = 400;
  const keys = Object.keys(profileUpdates);
  for (let i = 0; i < keys.length; i += batchSize) {
    const batch = {};
    for (let j = i; j < Math.min(i + batchSize, keys.length); j++) {
      batch[keys[j]] = profileUpdates[keys[j]];
    }
    await db.ref().update(batch);
  }

  const weekEndsAt = getWeekEndISO(nextWeekId);
  await db.ref("leagues/config").set({
    currentWeekId: nextWeekId,
    groupSize: LEAGUE_GROUP_SIZE,
    tierNames: LEAGUE_TIERS,
    weekEndsAt: weekEndsAt || null,
  });

  const groupCount = Object.keys(groups).length;
  log.info("[runWeeklyLeagueReset]", { nextWeekId, groups: groupCount, users: keys.length / 3 });
  return { weekId: nextWeekId, groups: groupCount, usersAssigned: keys.length / 3 };
}

/** Manuel tetikleme: Haftalık lig sıfırlama. */
exports.runWeeklyLeagueReset = onRequestJob(async (req, res) => {
  try {
    const result = await runWeeklyLeagueResetLogicModule();
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    log.error("runWeeklyLeagueReset error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
}, { secrets: ["JOBS_SHARED_SECRET"] });

// Logic fonksiyonları script/manuel çalıştırma için export
exports.runLockPredictionsLogic = runLockPredictionsLogicModule;
exports.runOracleResolutionLogic = runOracleResolutionLogicModule;
exports.runDistributeWinningsLogic = runDistributeWinningsLogicModule;
exports.runStashDripLogic = runStashDripLogicModule;
exports.runLeagueAssignmentLogic = runLeagueAssignmentLogicModule;
exports.runWeeklyLeagueResetLogic = runWeeklyLeagueResetLogicModule;

/** TEST: Manuel – Bitiş tarihi geçen tahminleri kilitler. (Production'da schedule'a çevrilecek.) */
exports.runLockPredictions = onRequestJob(async (req, res) => {
  try {
    const result = await runLockPredictionsLogicModule();
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    log.error("runLockPredictions error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
}, { secrets: ["JOBS_SHARED_SECRET"] });

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
      log.debug("Oracle resolved", { key });
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
exports.runOracleResolution = onRequestJob(async (req, res) => {
  try {
    const apiKey = process.env.OPENROUTER_API_KEY || null;
    const model = process.env.OPENROUTER_MODEL || null;
    const result = await runOracleResolutionLogicModule(apiKey, model);
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    log.error("runOracleResolution error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
}, { secrets: ["OPENROUTER_API_KEY", "JOBS_SHARED_SECRET"] });

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
const STREAK_MIN = 3;           // 3+ ardışık galibiyette bonus
const STREAK_MULTIPLIER = 1.2;  // Kazanç çarpanı (peg + stash)
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
        const currentStreak = user.currentStreak != null ? user.currentStreak : 0;
        const newStreak = currentStreak + 1;
        const multiplier = newStreak >= STREAK_MIN ? STREAK_MULTIPLIER : 1.0;
        const multipliedPayout = Math.round(payout * multiplier);
        const toSpendable = Math.round(multipliedPayout * (1 - STASH_PAYOUT_RATIO));
        const toStash = multipliedPayout - toSpendable;
        const newPeg = (user.pegCount || 0) + toSpendable;
        const newStash = (user.stashCount || 0) + toStash;
        profileUpdates[`profile/${el.userId}/pegCount`] = newPeg;
        profileUpdates[`profile/${el.userId}/stashCount`] = newStash;
        profileUpdates[`profile/${el.userId}/currentStreak`] = newStreak;
        profileUpdates[`profile/${el.userId}/lastStreakUpdatedAt`] = new Date().toISOString();
      }
    }
    const losingList = feedResult === FEED_RESULT_LIKE ? (tweet.unlikeList || []) : (tweet.likeList || []);
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
    if (Object.keys(profileUpdates).length > 0) {
      profileUpdates[`toldya/${key}/distributionDone`] = true;
      await getDb().ref().update(profileUpdates);
      log.debug("Distributed winnings", { key });
      distributed++;
    }
  }
  return { distributed };
}

/** TEST: Manuel – Kazanç dağıtımı. (Production'da schedule'a çevrilecek.) */
exports.runDistributeWinnings = onRequestJob(async (req, res) => {
  try {
    const result = await runDistributeWinningsLogicModule();
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    log.error("runDistributeWinnings error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
}, { secrets: ["JOBS_SHARED_SECRET"] });

// --- Callable: placeBet – Bahis tek noktadan, limit ve bakiye kontrolü ---
// enforceAppCheck: false → App Check zorunluluğu kapalı (cihaz/GMS hatası geçene kadar)
// Callable exports are registered from module (contract unchanged).
const _callables = registerCallables(functions);
exports.placeBet = _callables.placeBet;

// --- Callable: claimDailyBonus – Günlük giriş bonusu ---
exports.claimDailyBonus = _callables.claimDailyBonus;

// --- Callable: deleteAccount – Hesap silme (store requirement) ---
exports.deleteAccount = _callables.deleteAccount;

// --- Callable: moderateToldya – Admin manual moderation (statu=6) ---
exports.moderateToldya = _callables.moderateToldya;

// --- Callable: adminResolveToldya / adminDistributeWinningsForToldya ---
exports.adminResolveToldya = _callables.adminResolveToldya;
exports.adminDistributeWinningsForToldya = _callables.adminDistributeWinningsForToldya;

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
    log.info("Stash drip done", { dripped: processedCount });
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
exports.runStashDrip = onRequestJob(async (req, res) => {
  try {
    const result = await runStashDripLogicModule();
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    log.error("runStashDrip error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
}, { secrets: ["JOBS_SHARED_SECRET"] });

// --- Zamanlanmış: Her 10 dakikada bir çalışan sürümler ---
exports.scheduledLockPredictions = functions.pubsub
  .schedule(SCHEDULE_CRON)
  .onRun(async () => {
    try {
      const result = await runLockPredictionsLogic();
      log.info("[scheduledLockPredictions] done", result);
    } catch (e) {
      log.error("[scheduledLockPredictions] error", e);
    }
  });

exports.scheduledOracleResolution = functions.pubsub
  .schedule(SCHEDULE_CRON)
  .onRun(async () => {
    try {
      const result = await runOracleResolutionLogicModule();
      log.info("[scheduledOracleResolution] done", result);
    } catch (e) {
      log.error("[scheduledOracleResolution] error", e);
    }
  });

exports.scheduledDistributeWinnings = functions.pubsub
  .schedule(SCHEDULE_CRON)
  .onRun(async () => {
    try {
      const result = await runDistributeWinningsLogic();
      log.info("[scheduledDistributeWinnings] done", result);
    } catch (e) {
      log.error("[scheduledDistributeWinnings] error", e);
    }
  });

exports.scheduledStashDrip = functions.pubsub
  .schedule(SCHEDULE_CRON)
  .onRun(async () => {
    try {
      const result = await runStashDripLogic();
      log.info("[scheduledStashDrip] done", result);
    } catch (e) {
      log.error("[scheduledStashDrip] error", e);
    }
  });

/** Pazar 23:59 UTC: Haftalık lig sıfırlama (weeklyXp=0, sonraki hafta grupları atanır). */
const WEEKLY_LEAGUE_CRON = "59 23 * * 0";
exports.scheduledWeeklyLeagueReset = functions.pubsub
  .schedule(WEEKLY_LEAGUE_CRON)
  .onRun(async () => {
    try {
      const result = await runWeeklyLeagueResetLogic();
      log.info("[scheduledWeeklyLeagueReset] done", result);
    } catch (e) {
      log.error("[scheduledWeeklyLeagueReset] error", e);
    }
  });

// --- FCM Bildirim (Realtime Database Triggers) - notifications.js ---
const notifications = require("./notifications");
exports.onPredictionResolved = notifications.onPredictionResolved;
exports.onBetCreated = notifications.onBetCreated;
exports.onToldyaCreated = notifications.onToldyaCreated;
