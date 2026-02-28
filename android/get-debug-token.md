# Firebase App Check Debug Token Alma Rehberi

## Yöntem 1: Logcat'ten Alma (EN KOLAY)

1. **Android Studio'yu aç**
2. **Uygulamayı Debug modda çalıştır**
3. **Logcat sekmesini aç** (View → Tool Windows → Logcat)
4. **Filtre kutusuna şunu yaz:** `FirebaseAppCheck`
5. **Uygulama başladığında şu satırı bul:**
   ```
   FirebaseAppCheck: Enter this debug secret in the Firebase Console: XXXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
   ```
6. **Bu token'ı kopyala** (tire işaretleriyle birlikte)

---

## Yöntem 2: Terminal'den Alma

Android Studio Terminal'inde:

```bash
adb logcat | grep -i "FirebaseAppCheck"
```

Uygulamayı çalıştır ve token'ı bul.

---

## Firebase Console'a Ekleme

1. **Firebase Console'a git:** https://console.firebase.google.com/
2. **Projeni seç:** `casy-570c4`
3. **Sol menüden:** Build → **App Check**
4. **Android uygulamanı bul:** `com.casycorporate.casy`
5. **Üç nokta menüsüne tıkla** (sağ tarafta)
6. **"Manage debug tokens" seçeneğine tıkla**
7. **"Add debug token" butonuna tıkla**
8. **Token'ı yapıştır** (tire işaretleriyle birlikte)
9. **Kaydet**

---

## Önemli Notlar

- Debug token'lar sadece development için kullanılır
- Her cihaz/emülatör için farklı token olabilir
- Production'da App Check otomatik çalışır (debug token gerekmez)
- Token'ı ekledikten sonra uygulamayı yeniden başlat

---

## Sorun Giderme

### Token görünmüyorsa:
- Uygulamayı tamamen kapat ve yeniden başlat
- Logcat filtrelerini temizle
- `flutter clean` yap ve yeniden build et

### Hala çalışmıyorsa:
- Firebase Console'da App Check'i geçici olarak devre dışı bırak (sadece development için)
- Veya Play Integrity yerine Debug provider kullan
