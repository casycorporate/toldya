/**
 * Batch mantığını sırayla çalıştırır (Cloud Function deploy'u değil; yerel Node).
 * Kullanım: cd functions && node run-functions.js
 * Not: GOOGLE_APPLICATION_CREDENTIALS veya gcloud auth ile Firebase erişimi gerekir.
 */
const path = require("path");
const fs = require("fs");

// Yerel çalıştırmada Realtime Database URL (Firebase proje ID ile)
if (!process.env.DATABASE_URL) {
  const firebasercPath = path.join(__dirname, "..", ".firebaserc");
  let projectId = "casy-570c4";
  if (fs.existsSync(firebasercPath)) {
    try {
      const rc = JSON.parse(fs.readFileSync(firebasercPath, "utf8"));
      projectId = rc.projects?.default || projectId;
    } catch (_) {}
  }
  process.env.DATABASE_URL = `https://${projectId}-default-rtdb.firebaseio.com`;
}

const admin = require("firebase-admin");
if (!admin.apps.length) {
  admin.initializeApp({ databaseURL: process.env.DATABASE_URL });
}

const { runLockPredictionsLogic } = require("./jobs_logic");
const { runDistributeWinningsLogic, runStashDripLogic } = require("./tokenomics");

async function main() {
  console.log("=== Toldya batch (kilit → dağıtım → stash) ===\n");

  try {
    const lockResult = await runLockPredictionsLogic();
    console.log("1. runLockPredictionsLogic:", lockResult);
  } catch (e) {
    console.error("runLockPredictionsLogic hata:", e.message);
  }

  try {
    const distResult = await runDistributeWinningsLogic();
    console.log("2. runDistributeWinningsLogic:", distResult);
  } catch (e) {
    console.error("runDistributeWinningsLogic hata:", e.message);
  }

  try {
    const dripResult = await runStashDripLogic();
    console.log("3. runStashDripLogic:", dripResult);
  } catch (e) {
    console.error("runStashDripLogic hata:", e.message);
  }

  console.log("\n=== Bitti ===");
  process.exit(0);
}

main();
