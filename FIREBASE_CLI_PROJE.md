# Toldya – Firebase CLI (casycorporate@gmail.com)

Bu projede **sadece** `casycorporate@gmail.com` hesabı kullanılacak. Terminalde başka bir Google hesabı açıksa karışmaması için aşağıdaki sırayı uygulayın.

---

## 1. Hangi hesabın açık olduğunu kontrol et

```bash
cd /Users/cemaydin/Desktop/orbislas.ai/toldya
firebase login:list
```

Listede `casycorporate@gmail.com` yoksa veya aktif değilse 2. adıma geçin.

---

## 2. casycorporate@gmail.com ile giriş yap

**Sadece bu proje klasöründe** çalışırken, Firebase’i bu hesapla kullanmak için:

```bash
firebase login
```

Tarayıcı açılınca **casycorporate@gmail.com** ile giriş yapın. (Başka bir hesap açıksa tarayıcıda o hesabı çıkış yapıp casycorporate ile giriş yapabilirsiniz.)

---

## 3. Projeyi seç (casy-570c4)

```bash
firebase use
```

Çıktıda `casy-570c4` görünmeli. Değilse:

```bash
firebase use casy-570c4
```

---

## 4. Functions’ları deploy et

```bash
npm install --prefix functions
firebase deploy --only functions
```

İlk deploy biraz sürebilir. Bittiğinde `submitPrediction` (ve diğer fonksiyonlar) canlıya alınmış olur.

---

## 5. Başka projede başka hesap kullanacaksanız

Toldya dışında başka bir projede farklı bir Google hesabı kullanacaksanız, o projeye geçince tekrar:

```bash
firebase login
```

yapıp o projenin hesabıyla giriş yapmanız yeterli. Hesap “son giriş yapılan” olarak güncellenir; Toldya’ya dönünce tekrar `firebase login` ile casycorporate@gmail.com seçebilirsiniz.

---

## Özet komutlar (bu proje için)

```bash
cd /Users/cemaydin/Desktop/orbislas.ai/toldya
firebase login
firebase use casy-570c4
npm install --prefix functions
firebase deploy --only functions
```
