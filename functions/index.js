const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { onRequestJob } = require("./jobs");
const log = require("./logger");

const { runLockPredictionsLogic: runLockPredictionsLogicModule } = require("./jobs_logic");
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

/**
 * Zamanlanmış batch: kilit → kazanç dağıtımı → stash drip.
 * HTTP tetik: `runToldyaBatchJobs` (header `x-toldya-job-secret`).
 */
const SCHEDULE_CRON = "every 30 minutes";

/** Haftalık lig grupları (HTTP, `x-toldya-job-secret`). */
exports.runLeagueAssignment = onRequestJob(async (req, res) => {
  try {
    const result = await runLeagueAssignmentLogicModule();
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    log.error("runLeagueAssignment error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
}, { secrets: ["JOBS_SHARED_SECRET"] });

/** Haftalık lig sıfırlama (HTTP, `x-toldya-job-secret`). */
exports.runWeeklyLeagueReset = onRequestJob(async (req, res) => {
  try {
    const result = await runWeeklyLeagueResetLogicModule();
    res.status(200).json({ ok: true, ...result });
  } catch (e) {
    log.error("runWeeklyLeagueReset error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
}, { secrets: ["JOBS_SHARED_SECRET"] });

/**
 * Toldya pipeline tek istekte: kilit → dağıtım → stash drip.
 * Eski ayrı HTTP uçları (`runLockPredictions`, `runDistributeWinnings`, `runStashDrip`) kaldırıldı.
 */
exports.runToldyaBatchJobs = onRequestJob(async (req, res) => {
  try {
    const lock = await runLockPredictionsLogicModule();
    const distribute = await runDistributeWinningsLogicModule();
    const stash = await runStashDripLogicModule();
    res.status(200).json({ ok: true, lock, distribute, stash });
  } catch (e) {
    log.error("runToldyaBatchJobs error", e);
    res.status(500).json({ ok: false, error: e.message });
  }
}, { secrets: ["JOBS_SHARED_SECRET"] });

// --- Callable (App Check kapalı) ---
const _callables = registerCallables(functions);
exports.placeBet = _callables.placeBet;
exports.claimDailyBonus = _callables.claimDailyBonus;
exports.deleteAccount = _callables.deleteAccount;
exports.moderateToldya = _callables.moderateToldya;
exports.adminResolveToldya = _callables.adminResolveToldya;
exports.adminDistributeWinningsForToldya = _callables.adminDistributeWinningsForToldya;

// --- Zamanlanmış: Toldya batch (kilit + dağıtım + stash) ---
exports.scheduledToldyaBatchJobs = functions.pubsub
  .schedule(SCHEDULE_CRON)
  .onRun(async () => {
    try {
      const lock = await runLockPredictionsLogicModule();
      const distribute = await runDistributeWinningsLogicModule();
      const stash = await runStashDripLogicModule();
      log.info("[scheduledToldyaBatchJobs] done", { lock, distribute, stash });
    } catch (e) {
      log.error("[scheduledToldyaBatchJobs] error", e);
    }
  });

/** Pazar 23:59 UTC: haftalık lig sıfırlama. */
const WEEKLY_LEAGUE_CRON = "59 23 * * 0";
exports.scheduledWeeklyLeagueReset = functions.pubsub
  .schedule(WEEKLY_LEAGUE_CRON)
  .onRun(async () => {
    try {
      const result = await runWeeklyLeagueResetLogicModule();
      log.info("[scheduledWeeklyLeagueReset] done", result);
    } catch (e) {
      log.error("[scheduledWeeklyLeagueReset] error", e);
    }
  });

// --- RTDB tetikleyicileri (FCM) ---
const notifications = require("./notifications");
exports.onPredictionResolved = notifications.onPredictionResolved;
exports.onBetCreated = notifications.onBetCreated;
exports.onToldyaRejectedByAdmin = notifications.onToldyaRejectedByAdmin;
