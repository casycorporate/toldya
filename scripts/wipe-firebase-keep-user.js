/**
 * Firebase Realtime Database temizliği: Sadece belirtilen e-posta ile kullanıcı kalır.
 * Eski tahminleri (toldya) ve diğer kullanıcıları siler; takip verilerini kaldırır.
 *
 * Kullanım (functions dizininden):
 *   cd functions && GOOGLE_APPLICATION_CREDENTIALS=path/to/serviceAccountKey.json node ../scripts/wipe-firebase-keep-user.js
 *
 * Veya Firebase CLI ile:
 *   firebase use <project-id>
 *   node -r dotenv/config scripts/wipe-firebase-keep-user.js
 */
const admin = require("firebase-admin");
const path = require("path");

const KEEP_EMAIL = "jiwir26388@flosek.com";

async function main() {
  const dbUrl = process.env.DATABASE_URL || process.env.GCLOUD_DATABASE_URL;
  if (!admin.apps.length) {
    if (dbUrl) {
      admin.initializeApp({ databaseURL: dbUrl });
    } else {
      admin.initializeApp();
    }
  }
  const db = admin.database();
  const auth = admin.auth();

  let keepUid = null;
  try {
    const userRecord = await auth.getUserByEmail(KEEP_EMAIL);
    keepUid = userRecord.uid;
    console.log("Korunacak kullanıcı:", KEEP_EMAIL, "uid:", keepUid);
  } catch (e) {
    console.error("Kullanıcı bulunamadı:", KEEP_EMAIL, e.message);
    process.exit(1);
  }

  // 1) Tüm toldya kayıtlarını sil
  const toldyaRef = db.ref("toldya");
  const toldyaSnap = await toldyaRef.once("value");
  const toldyas = toldyaSnap.val();
  if (toldyas && typeof toldyas === "object") {
    const keys = Object.keys(toldyas);
    console.log("Silinecek toldya sayısı:", keys.length);
    for (const key of keys) {
      await db.ref("toldya").child(key).remove();
    }
  } else {
    console.log("toldya zaten boş.");
  }

  // 2) followers node'unu tamamen sil
  await db.ref("followers").remove();
  console.log("followers node silindi.");

  // 3) profile: Sadece keepUid kalsın, diğerlerini sil. Korunan kullanıcıdan followerList/followingList kaldır.
  const profileRef = db.ref("profile");
  const profileSnap = await profileRef.once("value");
  const profiles = profileSnap.val();
  if (profiles && typeof profiles === "object") {
    const uids = Object.keys(profiles);
    for (const uid of uids) {
      if (uid === keepUid) {
        await profileRef.child(uid).child("followerList").remove();
        await profileRef.child(uid).child("followingList").remove();
        await profileRef.child(uid).update({ followers: 0, following: 0 });
        console.log("Korunan profil güncellendi (takip listeleri kaldırıldı):", uid);
      } else {
        await profileRef.child(uid).remove();
        console.log("Profil silindi:", uid);
      }
    }
  }

  // 4) notification node'larını temizle (isteğe bağlı; tüm kullanıcı bildirimleri)
  const notifRef = db.ref("notification");
  const notifSnap = await notifRef.once("value");
  const notifs = notifSnap.val();
  if (notifs && typeof notifs === "object") {
    const userIds = Object.keys(notifs);
    for (const uid of userIds) {
      await notifRef.child(uid).remove();
    }
    console.log("notification node'ları temizlendi.");
  }

  console.log("Temizlik tamamlandı. Sadece", KEEP_EMAIL, "kaldı.");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
