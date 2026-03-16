// testNotifyAdmins.js
//
// Amaç: functions/notifications.js içindeki
// notifyAllAdminsPendingResolution(pendingCount) fonksiyonunu
// doğrudan çağırarak admin FCM bildirim akışını test etmek.

const admin = require("firebase-admin");

// 1) Buraya kendi service account JSON dosyanın yolunu yazmalısın.
//   - Dosyayı proje köküne koyup ismini serviceAccountKey.json yaparsan,
//     aşağıdaki varsayılan ayar işini görür.
const SERVICE_ACCOUNT_PATH = "./serviceAccountKey.json";

// 2) Buraya kendi Realtime Database URL'ini yazmalısın.
//   Örn: https://<project-id>-default-rtdb.europe-west1.firebasedatabase.app
const DATABASE_URL = "https://<project-id>.firebaseio.com";

function initFirebase() {
  try {
    if (admin.apps.length === 0) {
      const serviceAccount = require(SERVICE_ACCOUNT_PATH);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: DATABASE_URL,
      });
      console.log("[testNotifyAdmins] Firebase Admin initialized.");
    }
  } catch (e) {
    console.error(
      "[testNotifyAdmins] Firebase init error. SERVICE_ACCOUNT_PATH veya DATABASE_URL hatalı olabilir.",
      e
    );
    process.exit(1);
  }
}

async function main() {
  initFirebase();

  // functions/notifications.js içindeki fonksiyonu içe aktar.
  const {
    notifyAllAdminsPendingResolution,
  } = require("./functions/notifications");

  // Bu sayı bildirim başlığında gözükecek:
  // "X tahmin sonuç bekliyor"
  const pendingCount = 3;

  try {
    console.log(
      "[testNotifyAdmins] Calling notifyAllAdminsPendingResolution with pendingCount =",
      pendingCount
    );
    const sentCount = await notifyAllAdminsPendingResolution(pendingCount);
    console.log(
      "[testNotifyAdmins] Bildirim gönderilen admin sayısı:",
      sentCount
    );
  } catch (e) {
    console.error("[testNotifyAdmins] Hata:", e);
  } finally {
    // Küçük gecikme verip Node sürecini kapatıyoruz.
    setTimeout(() => process.exit(0), 1000);
  }
}

main();

