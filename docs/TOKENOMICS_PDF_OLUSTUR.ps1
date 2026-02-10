# Tokenomics tasarim belgesini PDF olarak olusturur.
# Kullanim: .\TOKENOMICS_PDF_OLUSTUR.ps1
# Gereksinim: Chrome veya Edge yuklu olmali (headless print-to-pdf destegi icin).

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlPath = Join-Path $scriptDir "TOKENOMICS_TASARIM.html"
$pdfPath  = Join-Path $scriptDir "TOKENOMICS_TASARIM.pdf"

if (-not (Test-Path $htmlPath)) {
    Write-Host "HATA: TOKENOMICS_TASARIM.html bulunamadi: $htmlPath"
    exit 1
}

$chromePaths = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
)
$edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"

$browser = $null
foreach ($p in $chromePaths) {
    if (Test-Path $p) { $browser = $p; break }
}
if (-not $browser -and (Test-Path $edgePath)) { $browser = $edgePath }

if (-not $browser) {
    Write-Host "Chrome veya Edge bulunamadi. PDF icin:"
    Write-Host "  1. docs\TOKENOMICS_TASARIM.html dosyasini tarayicida acin"
    Write-Host "  2. Ctrl+P ile Yazdir -> Hedef olarak 'PDF olarak kaydet' secin"
    Write-Host "  3. TOKENOMICS_TASARIM.pdf adiyla docs klasorune kaydedin"
    exit 1
}

$htmlUri = [System.Uri]::new($htmlPath).AbsoluteUri
Write-Host "PDF olusturuluyor: $pdfPath"
& $browser --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="$pdfPath" "$htmlUri"
if (Test-Path $pdfPath) {
    Write-Host "Tamamlandi: $pdfPath"
} else {
    Write-Host "PDF olusturulamadi. Yukaridaki manuel adimlari kullanin."
    exit 1
}
