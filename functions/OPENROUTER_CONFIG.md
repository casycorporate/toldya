# OpenRouter API Key – Secret Manager ile Ekleme

`functions.config()` Mart 2026’dan itibaren kaldırılacak. OpenRouter API key artık **Secret Manager** ile saklanıyor.

---

## 1. Key’i Secret olarak ekleme

### Yöntem A: Dosyadan (önerilen – 404 / “payload empty” hatalarını önler)

Proje kökünde (örn. `bendemistim`) **PowerShell**:

```powershell
# 1) functions klasöründe geçici dosya oluştur; aşağıdaki BURAYA_KEY kısmını
#    OpenRouter API key'inizle değiştirip tek satırda yapıştırın (sk-or-v1-... ile başlar)
Set-Content -Path "functions\openrouter-key.txt" -Value "BURAYA_KEY" -NoNewline -Encoding UTF8

# 2) Secret'ı bu dosyadan oluştur
firebase functions:secrets:set OPENROUTER_API_KEY --data-file "functions\openrouter-key.txt"

# 3) Dosyayı sil (key artık Secret Manager'da)
Remove-Item "functions\openrouter-key.txt" -Force -ErrorAction SilentlyContinue
```

`BURAYA_KEY` yerine **sadece** API key’i yazın, başında/sonunda boşluk veya satır sonu olmasın. İşlem bitince `openrouter-key.txt` silinir; **git’e eklemeyin**.

### Yöntem B: Interaktif

```bash
firebase functions:secrets:set OPENROUTER_API_KEY
```

İstendiğinde key’i yapıştırıp Enter’a basın. Bazen terminalde “payload empty” hatası alırsanız Yöntem A’yı kullanın.

---

## 2. Model (opsiyonel)

Varsayılan model: `openai/gpt-4o-mini`. Farklı model kullanmak için `functions/` klasöründe `.env` dosyası oluşturup ekleyin:

```
OPENROUTER_MODEL=anthropic/claude-3-haiku
```

`.env` dosyasını git’e eklemeyin (hassas bilgi olabilir). Deploy sırasında bu değişken fonksiyon ortamına yüklenir.

---

## 3. Deploy

Key’i veya `.env`’i değiştirdikten sonra fonksiyonları tekrar deploy edin:

```bash
firebase deploy --only functions
```

---

## 4. Özet

| Eski (deprecated) | Yeni |
|-------------------|------|
| `firebase functions:config:set openrouter.api_key="..."` | `firebase functions:secrets:set OPENROUTER_API_KEY` (komut sonrası key girilir) |
| `functions.config().openrouter?.api_key` | `process.env.OPENROUTER_API_KEY` (sadece `secrets: ["OPENROUTER_API_KEY"]` kullanan fonksiyonlarda) |

Sadece **runAiModeration** bu secret’a bağlı; diğer fonksiyonlar key’e erişmez.
