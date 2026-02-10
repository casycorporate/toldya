# Ben Demiştim – Token Ekonomisi (Tokenomics) Tasarım Belgesi

**Sürüm:** 1.0  
**Tarih:** Şubat 2025  
**Amaç:** Bahis limitleri, rütbe sistemi, token yenileme ve kademeli cüzdan için yazılım mimarisi ve entegrasyon spesifikasyonu.

---

## 1. Genel Bakış

Bu belge, sosyal tahmin oyununda:

- Kullanıcıyı içeride tutan ve tokenı değerli hissettiren **token yenileme** (günlük bonus, başarı görevleri),
- Sistemi suistimalden koruyan **bahis limitlendirme** ve **rütbe sistemi**,
- Önerilen **akış mantığı** (işlem kontrolü, kullanıcı/havuz limitleri),
- **Kademeli cüzdan** (harcanabilir + kilitli bakiye, 24 saatte bir sızdırma)

için **backend (Firebase Cloud Functions)** ve **Flutter** tarafında nereye, nasıl entegre edileceğini tanımlar.

---

## 2. Mevcut Durum Özeti

| Bileşen | Mevcut yapı |
|--------|---------------|
| Bakiye | Tek alan: `profile.pegCount`. Yeni kullanıcı: `AppIcon.pegCount` (50.000). |
| Bahis | Flutter: bottom sheet ile miktar; üst sınır = tüm bakiye. Sunucu tarafı limit yok. |
| Dağıtım | `runDistributeWinnings`: kazananlara `profile.pegCount` artırılıyor; komisyon %5. |
| Veri | Realtime Database: `tweet` (likeList/unlikeList, pegCount), `profile` (pegCount, predictorScore, rank). |

**Kritik eksik:** Bahis işlemi tamamen client’ta; sunucuda miktar/limit kontrolü olmadığı için güvenilir limitlendirme için bahis **Callable Cloud Function** üzerinden geçmelidir.

---

## 3. Callable: `placeBet` – Bahis İşlemi ve Limitler

### 3.1 Amaç

Tüm bahisler tek bir noktadan (Cloud Function) geçer; böylece:

- Kullanıcı bazlı max bahis (rütbe/XP),
- Bakiye oran limiti,
- Havuz bazlı limit (küçük tahminlerde tavan),

client’tan bağımsız ve güvenli uygulanır.

### 3.2 İmza ve Parametreler

**Fonksiyon adı:** `placeBet` (Callable HTTPS).

**Girdi (data):**

| Alan | Tip | Zorunlu | Açıklama |
|------|-----|---------|----------|
| `tweetId` | string | Evet | Tahmin (tweet) anahtarı. |
| `side` | number | Evet | 1 = Evet (like), 2 = Hayır (unlike). (lib/helper/constant.dart FeedResult ile uyumlu.) |
| `amount` | number | Evet | Bahis miktarı (token, tam sayı). |

**Çıktı (başarı):**

```json
{
  "ok": true,
  "newBalance": 12345,
  "newStashBalance": 5000,
  "message": "Bahis kabul edildi."
}
```

**Çıktı (hata):**

```json
{
  "ok": false,
  "code": "INSUFFICIENT_BALANCE",
  "message": "Yetersiz bakiye."
}
```

Olası `code` değerleri: `INSUFFICIENT_BALANCE`, `BET_LIMIT_USER`, `BET_LIMIT_POOL`, `PREDICTION_CLOSED`, `PREDICTION_NOT_FOUND`, `INVALID_AMOUNT`, `UNAUTHORIZED`.

### 3.3 Kontrol Sırası (Algoritma)

Fonksiyon içinde sıra:

1. **Yetki:** `context.auth` ile kullanıcı ID alınır; yoksa `UNAUTHORIZED`.
2. **Girdi:** `amount` > 0, `side` in [1, 2], `tweetId` dolu; değilse `INVALID_AMOUNT` / hata.
3. **Tahmin:** `tweet/{tweetId}` okunur. Yoksa `PREDICTION_NOT_FOUND`. `parentkey` varsa (cevap gönderi) işlem reddedilir.
4. **Kapanmış mı:** `statu !== STATU_LIVE` (0) ise `PREDICTION_CLOSED`.
5. **Kullanıcı profili:** `profile/{userId}` okunur. `spendableBalance = (pegCount || 0)`, rütbe/limit için `xp` veya `level` kullanılır.
6. **Kullanıcı bazlı limit (rütbe):**  
   `maxBetByRank = spendableBalance * rankMultiplier`  
   (Çaylak %10, Tahminci %25, Üstad %50 – aşağıda tablo.)  
   `if (amount > maxBetByRank)` → `BET_LIMIT_USER`, mesaj: "En fazla bakiyenizin %X'ini yatırabilirsiniz."
7. **Bakiye:** `if (amount > spendableBalance)` → `INSUFFICIENT_BALANCE`.
8. **Havuz bazlı limit:**  
   `totalPool = sumOfVote(likeList) + sumOfVote(unlikeList)`.  
   `if (totalPool < POOL_THRESHOLD)` (örn. 1000) → bu tahmine max bahis `MAX_BET_SMALL_POOL` (örn. 100).  
   `if (amount > maxBetForThisPrediction)` → `BET_LIMIT_POOL`, mesaj: "Havuz henüz küçük, maksimum X token yatırılabilir."
9. **Atomik işlem:**  
   - `profile/{userId}/pegCount` (veya harcanabilir bakiye alanı) `spendableBalance - amount` yapılır.  
   - `tweet/{tweetId}/likeList` veya `unlikeList` güncellenir (mevcut kullanıcı kaydı varsa pegCount artırılır, yoksa yeni eleman eklenir).  
   - Gerekirse `tweet/{tweetId}/likeCount` / `unlikeCount` güncellenir.  
   - Notification yazılabilir (mevcut mantıkla uyumlu).

Tüm validasyonlar geçtikten sonra tek bir `db.ref().update(updates)` ile atomik yapılması önerilir.

### 3.4 Sabitler (Backend)

```text
STATU_LIVE = 0
FEED_RESULT_LIKE = 1
FEED_RESULT_UNLIKE = 2

RANK_MULTIPLIER = {
  CAYLAK: 0.10,    // 0–500 XP
  TAHMINCI: 0.25,  // 500–2000 XP
  USTA: 0.50       // 2000+ XP
}

POOL_THRESHOLD = 1000
MAX_BET_SMALL_POOL = 100
```

XP sınırları (0–500, 500–2000, 2000+) backend veya paylaşılan config’te tutulur.

### 3.5 Veritabanı Şeması (Realtime DB) – placeBet için

**Mevcut (değişmez):**

- `tweet/{tweetId}`: likeList, unlikeList (UserPegModel: userId, pegCount), statu, endDate, userId, vb.
- `profile/{userId}`: pegCount, predictorScore, rank, vb.

**Eklenecek (rütbe/limit için):**

- `profile/{userId}/xp`: number (0 başlangıç). İsteğe bağlı: `level` (hesaplanan veya saklanan).

**placeBet sonrası güncellenecek:**

- `profile/{userId}/pegCount` (veya spendable balance alanı) azalır.
- `tweet/{tweetId}/likeList` veya `unlikeList` güncellenir.

---

## 4. Rütbe (Seviye) Sistemi

### 4.1 Rütbe Tablosu

| Rütbe | XP aralığı | Bahis başı max (bakiye oranı) |
|--------|------------|-------------------------------|
| Çaylak | 0 – 500 | %10 |
| Tahminci | 500 – 2000 | %25 |
| Üstad | 2000+ | %50 |

### 4.2 XP Kaynakları (Öneri)

- Tahmin açma (onaylanan): +XP
- Doğru tahmine bahis (kazanınca): +XP
- Günlük giriş: +XP (veya sadece token)
- Başarı görevleri: +XP ve/veya token

XP güncellemesi: dağıtım fonksiyonunda veya ayrı bir “grantXp” helper’ında; `profile/{userId}/xp` artırılır.

### 4.3 Level Hesaplama

`level` istenirse `xp`’den türetilebilir (örn. level = floor(xp / 500) + 1 veya sabit aralıklar). Flutter ve backend’de aynı formül kullanılmalı.

---

## 5. Token Yenileme Stratejileri

### 5.1 Günlük Giriş Bonusu (Daily Check-in)

**Amaç:** Bakiye sıfıra insa bile kullanıcıyı oyunda tutmak; alışkanlık yaratmak.

**DB:**

- `profile/{userId}/lastDailyClaimAt`: ISO timestamp (son bonus alım zamanı).
- Bonus miktarı: sabit (örn. 500 token) veya streak’e göre artan.

**Backend:**

- Callable: `claimDailyBonus` veya HTTP (auth gerekli).
- Mantık: Aynı takvim gününde (UTC veya Türkiye) ikinci claim yapılamaz. `lastDailyClaimAt` ile kontrol; geçerliyse `pegCount` artır, `lastDailyClaimAt` güncelle.

**Flutter:**

- Ana sayfa veya profil üstünde “Bugünkü bonusu al” butonu; sadece claim edilmemişse aktif.

### 5.2 Başarı Görevleri (Achievements)

**Örnek görevler:**

- “3 tahmin paylaş” → token (ve/veya XP).
- “5 tahmine oy ver” → token (ve/veya XP).

**DB:**

- `profile/{userId}/achievements`: tamamlanan görev id’leri (array veya map).
- İsteğe bağlı: `achievementDefinitions` (Realtime DB veya Firestore) – id, koşul, ödül.

**Backend:**

- Görev ilerlemesi: mevcut veriden hesaplanabilir (tweet sayısı userId’ye göre; likeList/unlikeList’te userId geçiş sayısı).  
- Tamamlama ve ödül: Zamanlanmış fonksiyon veya “etkileşim sonrası” tetikleyici (ör. tahmin paylaşımı/oy sonrası) bir fonksiyon; koşul sağlandıysa `achievements` güncelle ve `pegCount`/`xp` artır.

**Flutter:**

- Görev listesi ekranı; tamamlananlar işaretli, ödül gösterilir.

---

## 6. Kademeli Cüzdan (Harcanabilir + Kilitli)

### 6.1 Model

- **Harcanabilir bakiye:** Bahiste kullanılan. Mevcut `pegCount` bu role devam eder.
- **Kilitli bakiye (Stash):** Kazançların bir kısmı buraya gider; kullanıcı doğrudan bahiste kullanamaz.
- **Sızdırma (drip):** Harcanabilir bakiye 0 ise, her 24 saatte bir kilitli bakiyeden sabit veya oranlı miktar harcanabilir bakiyeye aktarılır.

### 6.2 DB Alanları

- `profile/{userId}/pegCount`: harcanabilir (mevcut).
- `profile/{userId}/stashCount`: kilitli bakiye (yeni).
- `profile/{userId}/lastStashDripAt`: son sızdırma zamanı (yeni).

### 6.3 Dağıtımda Kazanç Payı

`runDistributeWinnings` (veya eşdeğer) güncellenir:

- Kazanan için hesaplanan `payout`’un tamamı veya bir oranı (örn. %70) `pegCount`’a.
- Kalan oran (örn. %30) `stashCount`’a eklenir.

Örnek: `pegCount += payout * 0.7`, `stashCount += payout * 0.3`. Oranlar sabit veya konfigüre edilebilir.

### 6.4 Stash Sızdırma (Drip) – Zamanlanmış İş

**Sıklık:** Günde bir (örn. 00:05 UTC).

**Mantık:**

- Tüm `profile` kayıtları taranır (veya `pegCount === 0` ve `stashCount > 0` filtreli sorgu; Realtime DB’de index/query kısıtlarına dikkat).
- Her kullanıcı için: `lastStashDripAt` son 24 saatten eskiyse ve `pegCount === 0` ve `stashCount > 0` ise:
  - `dripAmount = min(DEFAULT_DRIP_AMOUNT, stashCount)` (örn. 200 token).
  - `stashCount -= dripAmount`, `pegCount += dripAmount`, `lastStashDripAt = now`.
- Büyük kullanıcı sayısında batch (örn. 500’er) işlenebilir.

---

## 7. Flutter Tarafı Uyum

### 7.1 Bahis Akışı

- Mevcut: Kullanıcı miktar seçer → doğrudan `kDatabase.child('tweet')... set()` ve `userModel.pegCount -= _period`.
- Yeni: Kullanıcı miktar seçer → **sadece** Callable `placeBet(tweetId, side, amount)` çağrılır. Başarıda: lokal `userModel.pegCount` (ve varsa stash) güncellenir; hata koduna göre mesaj gösterilir (“En fazla bakiyenizin %20’sini yatırabilirsiniz”, “Havuz küçük, max 100 token” vb.).
- `maxVal` (slider üst sınırı): Backend’den dönen `maxBetForUser` veya client’ta aynı formülle hesaplanır (rütbe oranı × bakiyenin min’i, havuz limiti). Böylece kullanıcı zaten izin verilen aralıkta seçim yapar.

### 7.2 Sabitler (constant.dart)

- Rütbe oranları ve XP sınırları backend ile aynı olacak şekilde sabit veya remote config eklenebilir.
- Küçük havuz eşiği (1000) ve max bahis (100) backend ile senkron tutulmalı.

### 7.3 Model (user.dart)

- `pegCount`: harcanabilir (mevcut).
- `stashCount`: kilitli bakiye (yeni, opsiyonel gösterim).
- `xp` veya `level`: rütbe ve limit hesaplaması için (yeni).

---

## 8. Özet Checklist (Uygulama Sırası)

| Sıra | Öğe | Backend | Flutter |
|------|-----|---------|---------|
| 1 | placeBet Callable + limitler | Yeni fonksiyon; validasyon + atomik güncelleme | Bahis ekranında Callable çağrısı; doğrudan DB yazımı kaldırılır |
| 2 | Rütbe/XP | profile’a xp (ve isteğe level); dağıtımda/etkileşimde XP artışı | maxVal = f(bakiye, xp, havuz); rütbe gösterimi |
| 3 | Günlük bonus | claimDailyBonus; lastDailyClaimAt | “Bugünkü bonusu al” UI |
| 4 | Kademeli cüzdan | stashCount, lastStashDripAt; dağıtımda stash payı; scheduled drip | stash gösterimi (opsiyonel) |
| 5 | Başarı görevleri | achievements; tamamlama + ödül fonksiyonu | Görev listesi ekranı |

---

## 9. Hata Kodları ve Mesajlar (placeBet)

| code | Mesaj (örnek) |
|------|-------------------------------|
| UNAUTHORIZED | Oturum açmanız gerekir. |
| INVALID_AMOUNT | Geçersiz bahis miktarı. |
| PREDICTION_NOT_FOUND | Tahmin bulunamadı. |
| PREDICTION_CLOSED | Bu tahmine artık bahis kapatıldı. |
| INSUFFICIENT_BALANCE | Yetersiz bakiye. |
| BET_LIMIT_USER | En fazla bakiyenizin %X'ini yatırabilirsiniz. |
| BET_LIMIT_POOL | Havuz henüz küçük, maksimum X token yatırılabilir. |

---

*Bu belge yazılım mimarisi ve entegrasyon tasarımı içerir; geliştirme sırasında referans alınabilir.*
