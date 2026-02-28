# SHA-1 ve SHA-256 Hash'lerini Alma Rehberi

## Yöntem 1: Android Studio Gradle ile (EN KOLAY)

### Adımlar:
1. **Android Studio'yu aç**
2. **Sağ tarafta Gradle sekmesini aç** (yoksa: View → Tool Windows → Gradle)
3. **Proje yapısını genişlet:**
   - `bendemistim` → `android` → `app` → `Tasks` → `android`
4. **`signingReport` görevini çift tıkla**
5. **Alttaki Run sekmesinde SHA-1 ve SHA-256 hash'lerini bul:**
   ```
   Variant: debug
   Config: debug
   Store: C:\Users\...\.android\debug.keystore
   Alias: AndroidDebugKey
   MD5: XX:XX:XX:...
   SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   SHA-256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   Valid until: ...
   ```

---

## Yöntem 2: Terminal/Command Prompt ile

### Windows PowerShell veya Command Prompt:

1. **Android Studio'nun Terminal sekmesini aç** (veya Windows Terminal)

2. **Proje klasörüne git:**
   ```powershell
   cd C:\Users\sinan.yilmaz\Desktop\bendemistim\android
   ```

3. **Gradle ile SHA hash'lerini al:**
   ```powershell
   .\gradlew signingReport
   ```

4. **Çıktıda SHA-1 ve SHA-256 hash'lerini bul**

---

## Yöntem 3: Keytool ile (Manuel)

### Adımlar:

1. **Java JDK'nın kurulu olduğundan emin ol**
   - Android Studio genellikle kendi JDK'sını kullanır
   - Path: `C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`

2. **PowerShell veya Command Prompt'u aç**

3. **Debug keystore için SHA hash'lerini al:**

   **PowerShell:**
   ```powershell
   & "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```

   **Veya eğer keytool PATH'teyse:**
   ```powershell
   keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```

4. **Çıktıda şunları göreceksin:**
   ```
   Certificate fingerprints:
        MD5:  XX:XX:XX:...
        SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
        SHA-256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   ```

---

## Yöntem 4: Android Studio'da Otomatik Script

Android Studio'nun Terminal sekmesinde şu komutu çalıştır:

```powershell
cd android
.\gradlew signingReport | Select-String -Pattern "SHA1|SHA-256" -Context 0,2
```

---

## Firebase Console'a Ekleme

1. **Firebase Console'a git:** https://console.firebase.google.com/
2. **Projeni seç:** `casy-570c4`
3. **Sol menüden:** ⚙️ → **Project settings**
4. **"Your apps" bölümünde** Android uygulamanı bul (`com.casycorporate.casy`)
5. **"SHA certificate fingerprints" bölümüne git**
6. **"Add fingerprint" butonuna tıkla**
7. **SHA-1 hash'ini yapıştır** (iki nokta üst üste ile ayrılmış format: `XX:XX:XX:...`)
8. **"Add fingerprint" ile SHA-256 hash'ini de ekle** (opsiyonel ama önerilir)
9. **Kaydet**

---

## Önemli Notlar

- **Debug keystore:** `C:\Users\sinan.yilmaz\.android\debug.keystore`
- **Store password:** `android`
- **Key alias:** `androiddebugkey`
- **Key password:** `android`

- **Release keystore için:** Eğer release build yapıyorsan, release keystore'un SHA hash'lerini de eklemen gerekir.

---

## Sorun Giderme

### Keytool bulunamıyorsa:
1. Android Studio'yu aç
2. File → Settings → Appearance & Behavior → System Settings → Android SDK
3. SDK Tools sekmesinde "Android SDK Build-Tools" işaretli olduğundan emin ol
4. Android Studio'nun Terminal sekmesini kullan (keytool otomatik PATH'te olur)

### Gradle komutu çalışmıyorsa:
- Android Studio'nun Terminal sekmesini kullan
- Veya Android Studio'da Gradle sekmesinden `signingReport` görevini çalıştır
