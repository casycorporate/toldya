# Bildirim Test Rehberi ve Hata Takibi

Bu rehber, uygulamadaki push bildirimlerini nasıl test edeceğinizi ve bildirim gelmediğinde hataları nereden takip edeceğinizi anlatır.

---

## 1. Bildirim Türleri ve Tetikleyiciler

| Senaryo | Ne zaman tetiklenir? | Kim bildirim alır? | Cloud Function |
|--------|------------------------|---------------------|----------------|
| **Tahminine bahis yapıldı** | Bir kullanıcı sizin tahmininize Evet/Hayır bahsi yaptığında | Tahminin sahibi (siz) | `onBetCreated` |
| **Tahmin sonuçlandı** | Tahmin `statu` değeri 2 (Ok) yapıldığında (Oracle sonuç girdi) | O tahmine bahis yapan herkes | `onPredictionResolved` |
| **Yeni takipçi** | Biri sizi takip ettiğinde | Takip edilen kullanıcı (siz) | `onFollowerCreated` |

Bildirimler **Cloud Functions** tarafından gönderilir. Tetikleyici: Realtime Database’de ilgili path’e yazı yapılması.

---

## 2. Test Senaryoları

### Senaryo A: “Tahminine bahis yapıldı” bildirimi

1. **İki hesap kullanın:** Cihaz 1 = Tahmin sahibi (A), Cihaz 2 veya emülatör = Bahis yapan (B).
2. **A hesabıyla** giriş yapın, bir tahmin oluşturun (bitiş tarihi en az 1 saat sonra). Tahmin onaylandıktan sonra akışta görünsün.
3. **A cihazında** uygulamayı arka plana alın veya kapatmayın; bildirim gelmesi için A’nın **FCM token’ı** veritabanında olmalı (aşağıda “FCM token kontrolü”ne bakın).
4. **B hesabıyla** giriş yapın, A’nın tahminine Evet veya Hayır bahsi yapın (Bendemistim ile token yatırın).
5. **Beklenen:** A cihazında “Tahminine Bahis Yapıldı!” bildirimi gelir.

**Tetikleyici:** `placeBet` Cloud Function’ı `notification/{tahminSahibiUserId}/{toldyaId}` path’ine yazı yapar → `onBetCreated` tetiklenir → A’nın `profile/{A}/fcmToken` değeri kullanılarak FCM gönderilir.

---

### Senaryo B: “Tahmin sonuçlandı” bildirimi

1. Bir tahminin **statu** değerini Realtime Database veya admin panelden **2 (Ok)** yapın (ve mümkünse `feedResult` 1 veya 2 olarak set edin).
2. O tahmine daha önce bahis yapmış kullanıcıların cihazlarında “Tahmin Sonuçlandı!” bildirimi gelmeli.

**Tetikleyici:** `toldya/{toldyaId}` **onUpdate** ile statu 2’ye geçince `onPredictionResolved` çalışır; `likeList` + `unlikeList` içindeki tüm kullanıcılara FCM gönderilir.

---

### Senaryo C: “Yeni takipçi” bildirimi

1. Takip işleminin **Realtime Database**’de `followers/{takipEdilenUserId}/{takipEdenUserId}` path’ine yazı yaptığından emin olun (kodda `followUser` vb. bu path’i yazıyorsa tetiklenir).
2. Takip edilen kullanıcıda “Yeni Takipçi!” bildirimi gelir.

**Not:** Projede takip akışı şu an `followers/...` path’ine yazmıyorsa bu bildirim hiç tetiklenmez; gerekirse takip koduna bu yazmayı eklemeniz gerekir.

---

## 3. Hata Takibi – Nereye Bakmalı?

### 3.1 Firebase Console – Functions logları

1. [Firebase Console](https://console.firebase.google.com) → Projeniz → **Functions**.
2. **Logs** sekmesini açın (veya Google Cloud Console → Logging).
3. Aşağıdaki mesajları arayın:

| Log mesajı | Anlamı |
|------------|--------|
| `[onBetCreated] tetiklendi: ownerId=..., toldyaId=...` | Bahis bildirimi tetikleyicisi çalıştı. |
| `[onBetCreated] tahmin sahibi (...) FCM token yok` | Bildirim alacak kullanıcının `profile/{userId}/fcmToken` alanı yok veya boş. |
| `[notifications] getFcmToken: profile/... için FCM token yok` | Aynı sebep: Token veritabanında yok. |
| `[notifications] sendFcm error: ...` | FCM gönderimi hata verdi (geçersiz token, kotası aşımı vb.). |
| `[onPredictionResolved] gönderilen=0` | Tahmin sonuçlandı ama hiçbir kullanıcıda token yok. |
| `[onPredictionResolved] gönderilen=3` | 3 kullanıcıya bildirim gönderildi. |

Bildirim gelmiyorsa önce bu loglara bakın: Tetikleniyor mu? Token bulunamıyor mu? Send hatası var mı?

---

### 3.2 Realtime Database – FCM token kontrolü

1. Firebase Console → **Realtime Database** → **Data**.
2. `profile` → bildirim alması gereken kullanıcının **userId**’si → `fcmToken` alanına bakın.

- **fcmToken yok veya boş:** O kullanıcı cihazda uygulamayı açıp giriş yaptıktan sonra token kaydedilir. Kullanıcı en az bir kez uygulamayı açmış ve giriş yapmış olmalı; `NotificationService` ve `authState.updateFCMToken()` token’ı `profile/{uid}/fcmToken` olarak yazar.
- **fcmToken dolu:** Cloud Functions bu token ile FCM gönderir. Hâlâ bildirim gelmiyorsa Functions loglarındaki `sendFcm error` satırına bakın.

---

### 3.3 Uygulama tarafı (Flutter) – Debug / Logcat

- **Android:** Android Studio veya VS Code ile debug run; **Logcat** filtresinde `FCM` veya `notification` arayın. `NotificationService` ve `cprint` çıktıları `developer.log` ve `print` ile konsola düşer.
- **iOS:** Xcode Console’da aynı şekilde FCM / bildirim loglarına bakın.

Örnek çıktılar:

- `[FCM] Device token: ...` → Token alındı.
- `FCM token saved to profile/...` → Token veritabanına yazıldı.
- `FCM foreground message: ...` → Uygulama öndeyken bildirim mesajı geldi.

Bildirim “hiç gelmiyor” ise önce Cloud Functions loglarında tetiklenme ve token/send durumunu kontrol etmek en hızlı yoldur.

---

## 4. Sık Karşılaşılan Nedenler

| Sorun | Olası neden | Ne yapmalı? |
|-------|-------------|-------------|
| “Tahminine bahis yapıldı” gelmiyor | Tahmin sahibinin `profile/{uid}/fcmToken` yok | Tahmin sahibi cihazda uygulamayı açıp giriş yapsın; token otomatik yazılır. |
| Hiçbir bildirim gelmiyor | Cloud Functions deploy edilmemiş veya hata alıyor | `firebase deploy --only functions` veya sadece ilgili fonksiyonları deploy edin; Functions loglarında hata var mı bakın. |
| Sadece bazen geliyor | Cihazda pil tasarrufu / bildirim kısıtı | Android’de uygulama için “tüm bildirimlere izin ver” / pil optimizasyonundan muaf tutun. |
| Tetikleniyor ama “sendFcm error” | Eski/yanlış FCM token, kotalar | Kullanıcı çıkış yapıp tekrar giriş yapsın (yeni token yazılır). Firebase/Cloud Messaging kotasına bakın. |

---

## 5. Özet Kontrol Listesi

- [ ] Cloud Functions deploy edildi mi? (`onBetCreated`, `onPredictionResolved`, `onFollowerCreated`)
- [ ] Bildirim alacak kullanıcının `profile/{userId}/fcmToken` alanı Realtime Database’de dolu mu?
- [ ] Bu kullanıcı en az bir kez uygulamada giriş yapmış mı? (Token giriş sonrası yazılıyor)
- [ ] Firebase Console → Functions → Logs’ta tetikleme ve “FCM token yok” / “sendFcm error” mesajları kontrol edildi mi?
- [ ] Test cihazında bildirim izni ve pil/battery optimizasyonu uygulama lehine ayarlandı mı?

Bu rehberi takip ederek hangi senaryoda bildirim beklediğinizi ve loglarda ne gördüğünüzü not ederseniz, sorunu daraltmak çok daha kolay olur.
