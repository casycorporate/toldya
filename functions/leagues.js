const { getDb } = require("./shared");
const log = require("./logger");

const LEAGUE_GROUP_SIZE = 30;
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
    tierNames: LEAGUE_TIERS,
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
  log.info("[leagues] assignment done", { weekId, groups: groupCount, users: entries.length });
  return { weekId, groups: groupCount, usersAssigned: entries.length };
}

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

  const zeroUpdates = {};
  for (const uid of Object.keys(profiles)) {
    zeroUpdates[`profile/${uid}/weeklyXp`] = 0;
  }
  if (Object.keys(zeroUpdates).length > 0) {
    await db.ref().update(zeroUpdates);
  }

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

  for (const [userId, p] of Object.entries(profiles)) {
    if (!p || typeof p !== "object") continue;
    if (!userIdToNextTier[userId]) userIdToNextTier[userId] = getTierFromXp(p.xp);
  }

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

  await db.ref(`leagues/weeks/${nextWeekId}/groups`).set(groups);
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
  log.info("[leagues] weekly reset done", { nextWeekId, groups: groupCount, users: keys.length / 3 });
  return { weekId: nextWeekId, groups: groupCount, usersAssigned: keys.length / 3 };
}

module.exports = { runLeagueAssignmentLogic, runWeeklyLeagueResetLogic };

