/**
 * Ben Demiştim - FCM Bildirim Cloud Functions (Realtime Database Triggers)
 *
 * Firestore Native olmadığı için tetikleyiciler Realtime Database üzerinden çalışır.
 * FCM token: profile/{userId}/fcmToken (mevcut yapı).
 *
 * RTDB yapısı (mevcut):
 * - profile/{userId}           → fcmToken, displayName, ...
 * - toldya/{toldyaId}          → statu (0=Live, 5=Locked, 2=Ok), feedResult, userId (creator), description, likeList, unlikeList
 * - notification/{userId}/{toldyaId} → placeBet yazınca type: Like/UnLike (tahmin sahibine yeni katılım)
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

const STATU_OK = 2;
const STATU_REJECTED_BY_ADMIN = 7;

function getDb() {
  return admin.database();
}

function getMessaging() {
  return admin.messaging();
}

/**
 * Realtime Database profile/{userId} içinden FCM token alır.
 * @param {string} userId
 * @returns {Promise<string|null>}
 */
async function getFcmToken(userId) {
  if (!userId) {
    console.log("[notifications] getFcmToken: userId boş");
    return null;
  }
  try {
    const snap = await getDb().ref("profile").child(userId).once("value");
    const data = snap.val();
    const token = data && data.fcmToken ? String(data.fcmToken).trim() : null;
    const hasToken = token && token.length > 0;
    if (!hasToken) {
      console.log("[notifications] getFcmToken: profile/" + userId + " için FCM token yok (cihaz uygulamayı açıp giriş yapmış olmalı)");
    }
    return hasToken ? token : null;
  } catch (e) {
    console.warn("[notifications] getFcmToken error for", userId, e.message);
    return null;
  }
}

/**
 * Tek bir cihaza FCM bildirimi gönderir.
 * @param {string} token
 * @param {string} title
 * @param {string} body
 * @param {Record<string, string>} data
 * @returns {Promise<boolean>}
 */
async function sendFcm(token, title, body, data) {
  if (!token || !title) return false;
  try {
    const message = {
      token,
      notification: {
        title: String(title).trim() || "Bildirim",
        body: body ? String(body).trim() : "",
      },
      data: data && typeof data === "object"
        ? Object.fromEntries(
            Object.entries(data).map(([k, v]) => [String(k), String(v)])
          )
        : {},
      android: {
        priority: "high",
        notification: { channelId: "high_importance_channel" },
      },
      apns: {
        payload: { aps: { sound: "default" } },
        fcmOptions: {},
      },
    };
    await getMessaging().send(message);
    console.log("[notifications] sendFcm: başarılı, title=" + (title || "").substring(0, 30));
    return true;
  } catch (e) {
    console.warn("[notifications] sendFcm error:", e.message, e.code || "");
    return false;
  }
}

/**
 * Tahmin sonuçlandığında: toldya statu 2 (Ok) olduğunda taraf seçen herkese bildirim.
 * Tetikleyici: toldya/{toldyaId} onUpdate
 */
exports.onPredictionResolved = functions.database
  .ref("toldya/{toldyaId}")
  .onUpdate(async (change, context) => {
    const toldyaId = context.params.toldyaId;
    const before = change.before.val();
    const after = change.after.val();

    if (!after || after.parentkey) return null;
    const prevStatu = before && (before.statu !== undefined) ? before.statu : null;
    const newStatu = after.statu;
    if (prevStatu === STATU_OK || newStatu !== STATU_OK) return null;

    const title = (after.description && String(after.description).trim()) || "Tahmin";
    const notifTitle = "Tahmin Sonuçlandı!";
    const notifBody = `'${title.substring(0, 50)}${title.length > 50 ? "…" : ""}' tahmininin sonucu belli oldu. Kazanıp kazanmadığını gör!`;
    // Standard payload: { type, id } + legacy keys for backward compatibility
    const dataPayload = { type: "toldya", id: toldyaId, toldyaId: toldyaId, legacyType: "prediction_result" };

    try {
      const likeList = Array.isArray(after.likeList) ? after.likeList : [];
      const unlikeList = Array.isArray(after.unlikeList) ? after.unlikeList : [];
      const userIds = new Set();
      likeList.forEach((e) => {
        const id = e && (e.userId || e);
        if (id) userIds.add(String(id));
      });
      unlikeList.forEach((e) => {
        const id = e && (e.userId || e);
        if (id) userIds.add(String(id));
      });

      let sent = 0;
      console.log("[onPredictionResolved] toldyaId=" + toldyaId + ", hedef kullanıcı sayısı=" + userIds.size);
      for (const uid of userIds) {
        const token = await getFcmToken(uid);
        if (token) {
          const ok = await sendFcm( token, notifTitle, notifBody, dataPayload );
          if (ok) sent++;
        }
      }
      console.log("[onPredictionResolved] gönderilen=" + sent + ", toldyaId=" + toldyaId);
      return null;
    } catch (e) {
      console.error("[onPredictionResolved] error", toldyaId, e);
      return null;
    }
  });

/**
 * Yeni katılım: notification/{userId}/{toldyaId} oluşturulduğunda (placeBet tarafından)
 * tahmin sahibine katılım bildirimi.
 * Tetikleyici: notification/{userId}/{toldyaId} onCreate
 */
exports.onBetCreated = functions.database
  .ref("notification/{userId}/{toldyaId}")
  .onCreate(async (snap, context) => {
    const ownerId = context.params.userId;
    const toldyaId = context.params.toldyaId;
    const data = snap.val();
    const type = data && data.type ? String(data.type) : "";
    const isStakeNotification = type.includes("Like") || type.includes("UnLike");
    if (!isStakeNotification) {
      console.log("[onBetCreated] atlandı: type=" + type + " (Like/UnLike değil), toldyaId=" + toldyaId);
      return null;
    }

    console.log("[onBetCreated] tetiklendi: ownerId=" + ownerId + ", toldyaId=" + toldyaId);
    try {
      const toldyaSnap = await getDb().ref("toldya").child(toldyaId).once("value");
      const toldya = toldyaSnap.val();
      const predictionTitle = (toldya && toldya.description)
        ? String(toldya.description).trim().substring(0, 50) + (toldya.description.length > 50 ? "…" : "")
        : "Tahmin";

      const notifTitle = "Tahminine yeni katılım!";
      const notifBody = `Bir kullanıcı '${predictionTitle}' tahminine puan ayırdı.`;
      // Katılım -> open toldya detail
      const dataPayload = { type: "toldya", id: toldyaId, toldyaId: toldyaId, legacyType: "prediction_stake" };

      const token = await getFcmToken(ownerId);
      if (token) {
        const ok = await sendFcm( token, notifTitle, notifBody, dataPayload );
        console.log("[onBetCreated] tahmin sahibine gönderildi: ownerId=" + ownerId + ", toldyaId=" + toldyaId + ", ok=" + ok);
      } else {
        console.log("[onBetCreated] tahmin sahibi (" + ownerId + ") FCM token yok, bildirim gönderilmedi");
      }
      return null;
    } catch (e) {
      console.error("[onBetCreated] error", toldyaId, e.message || e);
      return null;
    }
  });

/**
 * Yönetici tahmini reddetti: statu=7 ve moderasyon kaydı (manualModerationAt) yazıldığında oluşturucuya FCM.
 * Tetikleyici: toldya/{toldyaId} onUpdate
 */
exports.onToldyaRejectedByAdmin = functions.database
  .ref("toldya/{toldyaId}")
  .onUpdate(async (change, context) => {
    const toldyaId = context.params.toldyaId;
    const before = change.before.val();
    const after = change.after.val();
    if (!after || after.parentkey) return null;
    if (Number(after.statu) !== STATU_REJECTED_BY_ADMIN) return null;
    if (!after.manualModerationAt) return null;
    if (before && before.manualModerationAt === after.manualModerationAt) return null;

    const ownerId = after.userId && String(after.userId).trim();
    if (!ownerId) return null;

    const title = (after.description && String(after.description).trim()) || "Tahmin";
    const reason = (after.manualModerationReason && String(after.manualModerationReason).trim()) || "";
    const notifTitle = "Tahminin reddedildi";
    const shortTitle = title.length > 45 ? title.substring(0, 45) + "…" : title;
    const notifBody = reason
      ? `'${shortTitle}' — ${reason.length > 120 ? reason.substring(0, 120) + "…" : reason}`
      : `'${title.length > 50 ? title.substring(0, 50) + "…" : title}' tahminin yönetici incelemesinde reddedildi.`;
    const dataPayload = {
      type: "toldya",
      id: toldyaId,
      toldyaId: toldyaId,
      legacyType: "toldya_rejected_by_admin",
    };

    try {
      const token = await getFcmToken(ownerId);
      if (token) {
        const ok = await sendFcm(token, notifTitle, notifBody, dataPayload);
        console.log("[onToldyaRejectedByAdmin] toldyaId=" + toldyaId + ", ownerId=" + ownerId + ", ok=" + ok);
      } else {
        console.log("[onToldyaRejectedByAdmin] no FCM token, ownerId=" + ownerId);
      }
      return null;
    } catch (e) {
      console.error("[onToldyaRejectedByAdmin] error", toldyaId, e.message || e);
      return null;
    }
  });

