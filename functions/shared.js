const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Cloud Functions ortamında default app yoksa hemen başlat (soğuk start'ta "default app does not exist" önlenir).
if (!admin.apps.length) {
  const dbUrl = process.env.DATABASE_URL || functions.config().db?.url;
  if (dbUrl) admin.initializeApp({ databaseURL: dbUrl });
  else admin.initializeApp();
}

let _db = null;
function getDb() {
  if (!_db) _db = admin.database();
  return _db;
}

// Statu değerleri (lib/helper/constant.dart ile uyumlu)
const STATU_LIVE = 0;
const STATU_LOCKED = 5;
const STATU_OK = 2;
const STATU_PENDING_AI_REVIEW = 6;
const STATU_REJECTED_BY_AI = 7;

// FeedResult değerleri (lib/helper/constant.dart ile uyumlu)
const FEED_RESULT_LIKE = 1; // Evet
const FEED_RESULT_UNLIKE = 2; // Hayır

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

function sumOfVote(list) {
  if (!list || !Array.isArray(list)) return 0;
  return list.reduce((s, e) => s + (e.pegCount || 0), 0);
}

// --- Tokenomics: Rütbe ve bahis limitleri (lib/helper/constant.dart ile uyumlu) ---
const XP_CAYLAK_MAX = 500;
const XP_USTA_MIN = 2000;
const RANK_MULTIPLIER_CAYLAK = 0.10;
const RANK_MULTIPLIER_TAHMINCI = 0.25;
const RANK_MULTIPLIER_USTA = 0.50;
const POOL_THRESHOLD = 1000;
const MAX_BET_SMALL_POOL = 100;
const DAILY_BONUS_AMOUNT = 500;
const STASH_PAYOUT_RATIO = 0.3;
const STREAK_MIN = 3;
const STREAK_MULTIPLIER = 1.2;
const DRIP_AMOUNT = 200;
const DRIP_INTERVAL_MS = 24 * 60 * 60 * 1000;
const COMMISSION_RATE = 0.05;

function getRankMultiplier(xp) {
  const x = xp || 0;
  if (x < XP_CAYLAK_MAX) return RANK_MULTIPLIER_CAYLAK;
  if (x < XP_USTA_MIN) return RANK_MULTIPLIER_TAHMINCI;
  return RANK_MULTIPLIER_USTA;
}

module.exports = {
  functions,
  admin,
  getDb,
  safeString,
  deepSanitize,
  sumOfVote,
  getRankMultiplier,
  // constants
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
  DRIP_AMOUNT,
  DRIP_INTERVAL_MS,
  COMMISSION_RATE,
  STASH_PAYOUT_RATIO,
  STREAK_MIN,
  STREAK_MULTIPLIER,
};

