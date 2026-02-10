# Stash Drip (Kilitli Bakiye Sızdırma) Sistemi - Detaylı Açıklama

## 🎯 Amaç

Kullanıcının bakiyesi sıfıra indiğinde oyundan kopmamasını sağlamak ve "yarın yine gelecek" hissini vermek.

---

## 💡 Nasıl Çalışır?

### 1. Kazanç Dağıtımı (runDistributeWinnings)

Bir tahmin sonuçlandığında ve kullanıcı kazandığında:

- **%70** → `pegCount` (harcanabilir bakiye) - hemen bahis yapılabilir
- **%30** → `stashCount` (kilitli bakiye) - doğrudan bahiste kullanılamaz

**Örnek:**
```
Kullanıcı 1000 token kazandı:
├─ pegCount: +700 token (hemen kullanılabilir)
└─ stashCount: +300 token (kilitli)
```

---

### 2. Stash Drip İşlemi (runStashDrip)

Kullanıcının harcanabilir bakiyesi sıfıra indiğinde:

- Her **24 saatte bir**, stash'ten **200 token** (veya stash'te kalan miktar, hangisi azsa) otomatik olarak harcanabilir bakiyeye aktarılır.
- Bu işlem **sadece manuel olarak** tetiklenir (HTTP isteği ile).

---

## 📋 Koşullar ve Mantık

### Çalışma Koşulları

`runStashDrip` bir kullanıcıya token aktarmak için **3 koşul** kontrol eder:

1. ✅ **pegCount === 0** (harcanabilir bakiye tamamen sıfır)
2. ✅ **stashCount > 0** (kilitli bakiyede token var)
3. ✅ **Son drip'ten en az 24 saat geçmiş** (`lastStashDripAt` kontrolü)

### Aktarım Mantığı

```javascript
dripAmount = min(200, stashCount)
// Yani:
// - Eğer stash'te 200+ token varsa → 200 token aktarılır
// - Eğer stash'te 200'den az varsa → tümü aktarılır
```

---

## 🔄 Örnek Senaryo

### Başlangıç Durumu
```
Kullanıcı 1000 token kazandı:
├─ pegCount: 700
└─ stashCount: 300
```

### Adım 1: Kullanıcı tüm bakiyesini kaybetti
```
├─ pegCount: 0 (tüm bahisler kaybedildi)
└─ stashCount: 300 (hala kilitli)
```

### Adım 2: 24 saat sonra runStashDrip çalıştırıldı
```
├─ pegCount: 200 (stash'ten aktarıldı)
├─ stashCount: 100 (kalan)
└─ lastStashDripAt: 2025-02-09T10:00:00Z (zaman damgası)
```

**Sonuç:** Kullanıcı tekrar bahis yapabilir! 🎉

### Adım 3: Kullanıcı 200 token'ı da kaybetti
```
├─ pegCount: 0
└─ stashCount: 100
```

### Adım 4: 24 saat sonra tekrar runStashDrip çalıştırıldı
```
├─ pegCount: 100 (stash'te kalan son 100 token)
├─ stashCount: 0 (tamamı aktarıldı)
└─ lastStashDripAt: 2025-02-10T10:00:00Z
```

### Adım 5: Kullanıcı 100 token'ı da kaybetti
```
├─ pegCount: 0
└─ stashCount: 0
```

**Sonuç:** Artık stash'te token kalmadı. Kullanıcı yeni kazançlar beklemeli veya günlük bonus almalı.

---

## 🛠️ Teknik Detaylar

### Sabitler

```javascript
DRIP_AMOUNT = 200          // Her seferinde aktarılan maksimum token
DRIP_INTERVAL_MS = 86400000 // 24 saat (milisaniye cinsinden)
STASH_PAYOUT_RATIO = 0.3   // Kazancın %30'u stash'e gider
```

### Veritabanı Alanları

- `profile/{userId}/pegCount` - Harcanabilir bakiye
- `profile/{userId}/stashCount` - Kilitli bakiye
- `profile/{userId}/lastStashDripAt` - Son drip zamanı (ISO string)

### Fonksiyon İmzası

```javascript
exports.runStashDrip = functions.https.onRequest(async (req, res) => {
  // HTTP GET veya POST ile çağrılır
  // Yanıt: { "ok": true, "dripped": 5 }
  //        (5 kullanıcıya token aktarıldı)
})
```

---

## 🚀 Kullanım

### Manuel Tetikleme

**URL:**
```
https://[region]-[project-id].cloudfunctions.net/runStashDrip
```

**Örnek:**
```bash
# cURL ile
curl https://us-central1-bendemistim.cloudfunctions.net/runStashDrip

# Yanıt:
{
  "ok": true,
  "dripped": 5
}
```

**Firebase Console'dan:**
1. Functions sekmesine git
2. `runStashDrip` fonksiyonunu bul
3. "Test" butonuna tıkla veya URL'yi tarayıcıda aç

---

## ⚙️ Otomatik Zamanlama (İsteğe Bağlı)

Production'da otomatik çalışması için `functions/index.js` içine şunu ekleyebilirsiniz:

```javascript
// Günde bir kez, saat 05:00'te çalışır (UTC)
exports.scheduledStashDrip = functions.pubsub
  .schedule('0 5 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    return await runStashDripLogic();
  });
```

**Not:** Şu an bu kod **eklenmemiştir** - sadece manuel tetikleme aktif.

---

## 📊 Performans ve Limitler

- **Tüm kullanıcılar taranır** - büyük kullanıcı sayısında yavaşlayabilir
- **Atomik güncelleme** - tüm değişiklikler tek seferde uygulanır
- **24 saat kontrolü** - her kullanıcı için son drip zamanı kontrol edilir

**Öneri:** 1000+ kullanıcı varsa, batch işleme veya Firestore'a geçiş düşünülebilir.

---

## 🎮 Kullanıcı Deneyimi

### Kullanıcı Açısından:

1. **Kazandığında:** Tokenların bir kısmı hemen kullanılabilir, bir kısmı "tasarruf" olarak saklanır
2. **Bakiyesi sıfıra indiğinde:** "Param bitti ama yarın yine gelecek" hissi
3. **24 saat sonra:** Otomatik olarak 200 token gelir (stash'ten)
4. **Tekrar bahis yapabilir:** Oyundan kopmaz, devam eder

### Avantajlar:

- ✅ Kullanıcıyı oyunda tutar
- ✅ "All-in" stratejisini dengeler (stash'te birikim var)
- ✅ Tokenın değerli olduğunu hissettirir
- ✅ Manipülasyonu zorlaştırır (stash doğrudan kullanılamaz)

---

## 🔍 Debug ve Loglama

Fonksiyon çalıştığında console'a şu log yazılır:

```
Stash drip tamamlandı: 5 kullanıcıya token aktarıldı.
```

Her kullanıcı için:
- `lastStashDripAt` güncellenir
- `pegCount` ve `stashCount` değişir

---

## ⚠️ Önemli Notlar

1. **Manuel tetikleme:** Şu an sadece HTTP isteği ile çalışır, otomatik değil
2. **24 saat kuralı:** Aynı kullanıcıya 24 saat içinde iki kez drip yapılmaz
3. **Stash bitince:** Stash'te token kalmadığında drip yapılmaz
4. **Bakiye varsa:** `pegCount > 0` ise drip yapılmaz (sadece sıfır bakiyeliler için)

---

*Bu sistem, tokenomics tasarımının bir parçasıdır ve kullanıcı deneyimini iyileştirmek için tasarlanmıştır.*
