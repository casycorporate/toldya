# Firebase / DB Path Raporu (Twitter → Toldya)

## Projede AYNEN BIRAKILAN path'ler (Firebase ile ilgili)

Bu path'ler **kodda değiştirilmedi**. Uygulama şu an Firebase Realtime Database'deki mevcut yapıyla çalışmaya devam eder.

| Path / Kullanım | Dosya | Açıklama |
|-----------------|-------|----------|
| `kDatabase.child('tweet')` | feedState.dart, notificationState.dart | Ana gönderi (toldya) verisi. Tüm okuma/yazma/silme bu node altında. |
| `kDatabase.child('tweetImage')` | feedState.dart | Storage'da resim klasörü adı (Firebase Storage path). |
| `deleteFile(..., 'tweetImage')` | feedState.dart | Dosya silme için kullanılan string. |

**Özet:** Veritabanında kullanılan node adı hâlâ **`tweet`**, storage’da klasör adı **`tweetImage`**.

---

## DB’de “tweet” → “toldya” yapmak isterseniz

Firebase’te node adını değiştirmek **mevcut veriyi taşımak** demektir. İki yol var:

### Yol 1: Firebase Console ile manuel taşıma (küçük veri)

1. [Firebase Console](https://console.firebase.google.com) → Projeniz → **Realtime Database**.
2. **`tweet`** node’una tıklayın.
3. Üç nokta → **Export JSON** ile yedek alın.
4. Yeni bir node adı oluşturun: **`toldya`**.
5. Export ettiğiniz JSON içeriğini **`toldya`** altına import edin (veya elle kopyalayın).
6. Eski **`tweet`** node’unu silin (artık kullanmayacaksanız).
7. Bize “path’leri güncelledim” deyin; projede `child('tweet')` → `child('toldya')` ve `'tweetImage'` → `'toldyaImage'` olacak şekilde güncelleriz.

### Yol 2: Kodda path’i değiştirip yeni yapıyı kullanmak (yeni kurulum)

- Veriyi taşımak istemiyorsanız: Projede **sadece path’leri** `'tweet'` → `'toldya'`, `'tweetImage'` → `'toldyaImage'` yaparız.
- Bu durumda **eski `tweet` altındaki veriler kullanılmaz**; uygulama sadece **`toldya`** (ve yeni storage path’i) ile çalışır. Eski veriler DB’de kalsa bile uygulama onlara bakmaz.

---

## Storage (tweetImage)

- Firebase Storage’da klasör adı şu an **`tweetImage`** olarak kullanılıyor.
- Bunu **`toldyaImage`** yapmak isterseniz:
  - Ya Storage’da yeni klasör oluşturup dosyaları taşıyıp kodda path’i `'toldyaImage'` yaparız,
  - Ya da sadece kodda path’i `'toldyaImage'` yaparız; yeni yüklenen dosyalar bu isimle gider, eskiler `tweetImage`’da kalır.

Özet: **Projede tüm “twitter/tweet” → “toldya” değişti; sadece yukarıdaki Firebase path’ler bilerek bırakıldı. DB’de node adını değiştirmek tamamen sizin Console/Storage işleminiz; isterseniz path’leri koda göre sonra birlikte güncelleriz.**
