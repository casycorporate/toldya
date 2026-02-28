# SHA-1 hash'ini almak için PowerShell script
Write-Host "SHA-1 hash'ini alıyorum..." -ForegroundColor Green

# Debug keystore için SHA-1
$debugKeystore = "$env:USERPROFILE\.android\debug.keystore"
if (Test-Path $debugKeystore) {
    Write-Host "`nDebug keystore SHA-1:" -ForegroundColor Yellow
    keytool -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android | Select-String "SHA1:"
} else {
    Write-Host "Debug keystore bulunamadı: $debugKeystore" -ForegroundColor Red
}

Write-Host "`nNot: Bu SHA-1 hash'ini Firebase Console'a eklemen gerekiyor!" -ForegroundColor Cyan
