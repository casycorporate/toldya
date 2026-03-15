/**
 * Tüm zamanlanmış fonksiyon mantığını sırayla çalıştırır.
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

const {
  runLockPredictionsLogic,
  runClosePredictionsLogic,
  runOracleResolutionLogic,
  runDistributeRewardsLogic,
  runStashDripLogic,
} = require("./index");

async function main() {
  console.log("=== Fonksiyonlar çalıştırılıyor (saatlik job ile aynı sıra) ===\n");

  try {
    const lockResult = await runLockPredictionsLogic();
    console.log("1. runLockPredictionsLogic:", lockResult);
  } catch (e) {
    console.error("runLockPredictionsLogic hata:", e.message);
  }

  try {
    const closeResult = await runClosePredictionsLogic();
    console.log("2. runClosePredictionsLogic:", closeResult);
  } catch (e) {
    console.error("runClosePredictionsLogic hata:", e.message);
  }

  try {
    const resolveResult = await runOracleResolutionLogic();
    console.log("3. runOracleResolutionLogic:", resolveResult);
  } catch (e) {
    console.error("runOracleResolutionLogic hata:", e.message);
  }

  try {
    const distResult = await runDistributeRewardsLogic();
    console.log("4. runDistributeRewardsLogic:", distResult);
  } catch (e) {
    console.error("runDistributeRewardsLogic hata:", e.message);
  }

  try {
    const dripResult = await runStashDripLogic();
    console.log("5. runStashDripLogic:", dripResult);
  } catch (e) {
    console.error("runStashDripLogic hata:", e.message);
  }

  console.log("\n=== Bitti ===");
  process.exit(0);
}

main();
