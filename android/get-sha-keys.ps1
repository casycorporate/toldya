# SHA-1 ve SHA-256 Hash'lerini Alma Scripti
Write-Host "=== SHA-1 ve SHA-256 Hash'lerini Alıyorum ===" -ForegroundColor Green
Write-Host ""

# Debug keystore yolu
$debugKeystore = "$env:USERPROFILE\.android\debug.keystore"

if (-not (Test-Path $debugKeystore)) {
    Write-Host "HATA: Debug keystore bulunamadı: $debugKeystore" -ForegroundColor Red
    Write-Host "Android Studio'da bir kez uygulamayı çalıştırdıktan sonra tekrar deneyin." -ForegroundColor Yellow
    exit 1
}

Write-Host "Debug keystore bulundu: $debugKeystore" -ForegroundColor Cyan
Write-Host ""

# Keytool yolunu bul
$keytoolPaths = @(
    "$env:ANDROID_HOME\bin\keytool.exe",
    "$env:JAVA_HOME\bin\keytool.exe",
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
    "C:\Program Files\Java\*\bin\keytool.exe"
)

$keytool = $null
foreach ($path in $keytoolPaths) {
    if (Test-Path $path) {
        $keytool = $path
        break
    }
}

# Eğer keytool bulunamadıysa, PATH'te ara
if ($null -eq $keytool) {
    $keytool = Get-Command keytool -ErrorAction SilentlyContinue
    if ($keytool) {
        $keytool = $keytool.Source
    }
}

if ($null -eq $keytool) {
    Write-Host "HATA: keytool bulunamadı!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Çözüm 1: Android Studio'nun Terminal sekmesini kullan" -ForegroundColor Yellow
    Write-Host "Çözüm 2: Android Studio'da Gradle sekmesinden signingReport görevini çalıştır" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Veya şu komutu Android Studio Terminal'inde çalıştır:" -ForegroundColor Cyan
    Write-Host "  cd android" -ForegroundColor White
    Write-Host "  .\gradlew signingReport" -ForegroundColor White
    exit 1
}

Write-Host "Keytool bulundu: $keytool" -ForegroundColor Cyan
Write-Host ""
Write-Host "SHA hash'lerini alıyorum..." -ForegroundColor Yellow
Write-Host ""

# SHA hash'lerini al
$output = & $keytool -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "HATA: Keytool çalıştırılamadı!" -ForegroundColor Red
    Write-Host $output
    exit 1
}

# SHA-1 ve SHA-256 hash'lerini bul
$sha1 = $output | Select-String -Pattern "SHA1:\s+([A-F0-9:]+)" | ForEach-Object { $_.Matches.Groups[1].Value }
$sha256 = $output | Select-String -Pattern "SHA256:\s+([A-F0-9:]+)" | ForEach-Object { $_.Matches.Groups[1].Value }

Write-Host "=== SONUÇLAR ===" -ForegroundColor Green
Write-Host ""
if ($sha1) {
    Write-Host "SHA-1:" -ForegroundColor Cyan
    Write-Host $sha1 -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "SHA-1 bulunamadı!" -ForegroundColor Red
}

if ($sha256) {
    Write-Host "SHA-256:" -ForegroundColor Cyan
    Write-Host $sha256 -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "SHA-256 bulunamadı!" -ForegroundColor Red
}

Write-Host "=== Firebase Console'a Ekleme ===" -ForegroundColor Green
Write-Host ""
Write-Host "1. Firebase Console'a git: https://console.firebase.google.com/" -ForegroundColor Yellow
Write-Host "2. Projeni seç: casy-570c4" -ForegroundColor Yellow
Write-Host "3. Sol menüden: ⚙️ → Project settings" -ForegroundColor Yellow
Write-Host "4. 'Your apps' bölümünde Android uygulamanı bul" -ForegroundColor Yellow
Write-Host "5. 'SHA certificate fingerprints' bölümüne git" -ForegroundColor Yellow
Write-Host "6. 'Add fingerprint' butonuna tıkla" -ForegroundColor Yellow
if ($sha1) {
    Write-Host "7. SHA-1 hash'ini yapıştır: $sha1" -ForegroundColor Cyan
}
if ($sha256) {
    Write-Host "8. SHA-256 hash'ini de ekle: $sha256" -ForegroundColor Cyan
}
Write-Host "9. Kaydet" -ForegroundColor Yellow
Write-Host ""
