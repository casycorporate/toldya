# FCM Bildirim Cloud Functions (Realtime Database)

Bu modül, **Realtime Database** tetikleyicileri ile 3 senaryoda FCM bildirimi gönderir. Firestore gerekmez (Firestore Native olmayan projelerde çalışır).

## Ön koşul

- **FCM token:** Realtime Database `profile/{userId}/fcmToken` alanında tutulur (mevcut yapı).

## Realtime Database yapısı (mevcut)

| Yol | Açıklama |
|-----|----------|
| `profile/{userId}` | `fcmToken`, `displayName`, `userName`, `name` |
| `toldya/{toldyaId}` | `statu` (0=Live, 5=Locked, **2=Ok**), `feedResult`, `userId` (sahip), `description`, `likeList`, `unlikeList` |
| `notification/{userId}/{toldyaId}` | placeBet yazınca `type: Like/UnLike` (tahmin sahibine yeni bahis) |
| `followers/{followedUserId}/{followerId}` | Takip edildiğinde yazılırsa “yeni takipçi” bildirimi gider |

## Fonksiyonlar

| Fonksiyon | Tetikleyici | Açıklama |
|-----------|-------------|----------|
| `onPredictionResolved` | `toldya/{toldyaId}` **onUpdate** | `statu` 2 (Ok) olduğunda tahmine bahis yapan herkese bildirim. |
| `onBetCreated` | `notification/{userId}/{toldyaId}` **onCreate** | placeBet tahmin sahibine notification yazınca “Tahminine bahis yapıldı” bildirimi. |
| `onFollowerCreated` | `followers/{followedUserId}/{followerId}` **onCreate** | Bu path yazıldığında takip edilen kullanıcıya “Yeni takipçi” bildirimi. |

**Takipçi:** Takip işleminde şu an `followers/...` path’ine yazılmıyorsa “yeni takipçi” bildirimi gitmez. İstemek için takip akışında `followers/{followedUserId}/{followerId} = 1` (veya boş obje) yazın.

## Data payload (deep link)

- **Tahmin sonuçlandı / Tahminine bahis:** `{ type: 'prediction_result', id: predictionId }` → uygulama `FeedPostDetail` açabilir.
- **Yeni takipçi:** `{ type: 'new_follower', id: followerUserId }` → uygulama `ProfilePage` açabilir.

## Deploy

```bash
cd functions
npm install
firebase deploy --only functions
```

Sadece bildirim fonksiyonlarını deploy etmek için:

```bash
firebase deploy --only functions:onPredictionResolved,functions:onBetCreated,functions:onFollowerCreated
```
