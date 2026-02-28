# Tam temizlik ve rebuild scripti
Write-Host "=== Flutter ve Android Temizlik ===" -ForegroundColor Green

# Flutter temizlik
Write-Host "`n1. Flutter clean..." -ForegroundColor Yellow
flutter clean

# Build klasörlerini temizle
Write-Host "`n2. Build klasörlerini temizliyorum..." -ForegroundColor Yellow
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
if (Test-Path "android\build") { Remove-Item -Recurse -Force "android\build" }
if (Test-Path "android\app\build") { Remove-Item -Recurse -Force "android\app\build" }
if (Test-Path "android\.gradle") { Remove-Item -Recurse -Force "android\.gradle" }

# Gradle cache temizle
Write-Host "`n3. Gradle cache temizliyorum..." -ForegroundColor Yellow
cd android
if (Test-Path ".gradle") { Remove-Item -Recurse -Force ".gradle" }
.\gradlew clean --no-daemon
cd ..

Write-Host "`n=== Temizlik tamamlandı! ===" -ForegroundColor Green
Write-Host "Şimdi Android Studio'da:" -ForegroundColor Cyan
Write-Host "1. Build > Clean Project" -ForegroundColor White
Write-Host "2. Build > Rebuild Project" -ForegroundColor White
Write-Host "3. Uygulamayı cihazdan sil ve yeniden yükle" -ForegroundColor White
