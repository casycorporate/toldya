# Yapay Zeka Entegrasyonu – Mimari Özet

Bu doküman, Ben Demiştim uygulamasında **gönderi moderasyonu** (topluluk kuralları + tahmin tutarlılığı) ve **15 dakikalık işte tahmin tutarlılık kontrolü + dağıtım** için kullanılabilecek teknolojileri ve akışı **sadece mimari seviyede** açıklar. Geliştirme yapılmaz; sadece tasarım ve teknoloji seçenekleri çıkarılır.

---

## 1. Statu (Durum) Akışı

Gönderi yaşam döngüsü aşağıdaki `statu` değerleriyle yönetilir:

| Statu | Sabit | Açıklama |
|-------|--------|----------|
| 0 | statusLive | Yayında; tahmin alınabilir (endDate’e kadar). |
| 5 | statusLocked | Bitiş tarihi geçti; tahmin alımı kapalı, akışta görünmeye devam eder. |
| 6 | statusPendingAiReview | Veritabanına kaydedildi; AI incelemesi bekliyor, akışta görünmez. |
| 7 | statusRejectedByAi | AI tarafından reddedildi (kural/tutarlılık). |

**Akış özeti:**

1. Kullanıcı gönderiyi yazar → **hemen yayınlanmaz**; `statu = 6` (statusPendingAiReview) ile **veritabanına kaydedilir**.
2. Arka planda bir iş (örn. zamanlanmış Cloud Function) **toplu (bulk)** olarak `statu = 6` kayıtlarını okur.
3. Bu kayıtlar **yapay zeka servisi**ne gönderilir: topluluk kuralları, tahminin tutarlı olup olmadığı ve ileride eklenecek kriterlere uygunluk kontrol edilir.
4. **Uygunsa** → `statu = 0` (statusLive) yapılır; gönderi akışta görünür ve tahmin alınabilir.
5. **Uygun değilse** → `statu = 7` (statusRejectedByAi) yapılır; akışta görünmez.
6. Bitiş tarihi geldiğinde mevcut iş (örn. 5 dk’da bir) `statu = 5` (statusLocked) yapar; **tahmin alımı kapanır**, gönderi **akışta görünmeye devam eder**.
7. Sonuçlandırma ve dağıtım mevcut mantıkla devam eder; 15 dk’da bir çalışan işte isteğe bağlı olarak **AI ile tahmin tutarlılığı** kontrolü ve ardından **dağıtım** yapılabilir.

---

## 2. Veri Akışı (Yüksek Seviye)

- **Kayıt:** Flutter uygulaması gönderiyi Realtime Database’e `statu: 6` ile yazar.
- **Toplu okuma:** Zamanlanmış veya tetiklenen bir backend işi `tweet` node’unda `statu === 6` olan kayıtları toplu okur.
- **AI çağrısı:** Bu kayıtlar (metin + gerekirse meta veri) bir AI API’ye gönderilir; yanıt: onay / red (ve isteğe bağlı gerekçe).
- **Güncelleme:** Onaylananlar `statu: 0`, reddedilenler `statu: 7` olacak şekilde Realtime Database güncellenir.
- **15 dk iş:** Dağıtım işi öncesi isteğe bağlı AI tahmin tutarlılık kontrolü eklenebilir.

### 2.1 Sonuçlandırma ve Dağıtımın Ayrılması

**Sonuçlandırma** (oracle/manuel sonuç → `feedResult`, `statu=Ok`) ile **dağıtım** (kazanç payı → `profile.pegCount`, `tweet.distributionDone`) **iki ayrı fonksiyon** olarak tutulur:

| Avantaj | Açıklama |
|--------|----------|
| **Sorumluluk tekliği** | Her fonksiyon tek bir iş yapar; okunabilirlik ve bakım artar. |
| **Test / manuel kontrol** | Sonuçları doğruladıktan sonra dağıtımı ayrı tetikleyebilirsiniz. |
| **Hata izolasyonu** | Oracle hatası dağıtımı bozmaz; dağıtım hatası sonuçlandırmayı geri almaz. |
| **Zamanlama esnekliği** | İstenirse sonuçlandırma 10 dk, dağıtım 15 dk gibi farklı aralıklarda çalışabilir. |

Kodda: **runOracleResolution** (sonuçlandırma), **runDistributeWinnings** (dağıtım).

---

## 3. Yapay Zeka ile İletişim İçin Kullanılabilecek Teknolojiler

**Seçilen çözüm:** Kontroller [OpenRouter](https://openrouter.ai/) ile yapılacak (detay: Bölüm 4).

Aşağıdaki seçenekler **mimari** açıdan alternatif olarak uygundur.

### 3.1 Bulut / Yönetilen API’ler

- **OpenAI API (GPT-4 / GPT-4o)**  
  - REST veya resmi SDK ile çağrı.  
  - Moderation + metin analizi (tahmin tutarlılığı, kriterler) tek veya ayrı endpoint’lerle kullanılabilir.  
  - Firebase Cloud Functions’dan HTTP ile çağrılabilir.

- **Google Cloud (Vertex AI)**  
  - Gemini modelleri ile metin sınıflandırma / uygunluk kontrolü.  
  - Firebase ile aynı ekosistemde; Cloud Functions veya Cloud Run’dan erişilebilir.

- **Google AI (Generative Language API)**  
  - Gemini API’ye doğrudan erişim.  
  - Cloud Functions’da `fetch` veya Google client kütüphaneleri ile kullanılabilir.

- **Azure OpenAI**  
  - OpenAI uyumlu API; kurumsal / bölgesel dağıtım ihtiyacı varsa değerlendirilebilir.

- **Anthropic Claude (AWS / API)**  
  - Uzun metin ve politika metinleri için uygun; HTTP API ile Cloud Functions’dan çağrılabilir.

### 3.2 Firebase / GCP Entegrasyonu

- **Firebase Cloud Functions (1. veya 2. nesil)**  
  - Zamanlanmış fonksiyon: belirli aralıklarla `statu = 6` kayıtlarını okuyup AI’a gönderir, sonucu DB’e yazar.  
  - 15 dk’lık iş: mevcut dağıtım fonksiyonunun önüne AI tutarlılık adımı eklenebilir.  
  - AI ile iletişim: Node.js ortamında `fetch` veya ilgili SDK (OpenAI, Google, vb.) kullanılır.

- **Firebase Extensions**  
  - “Trigger from Realtime Database” veya “Scheduled” türü extension’lar ile tetikleme yapılabilir; asıl AI mantığı yine kendi fonksiyonunuzda veya harici bir serviste olur.

- **Cloud Run / Cloud Tasks**  
  - Daha ağır veya uzun süren AI işleri için: Cloud Function tetikler, Cloud Run’da çalışan bir servis bulk kayıtları işleyip AI’ı çağırabilir.

### 3.3 Mimari Tercih Özeti

- **Önerilen temel mimari:**  
  **Firebase Realtime Database** (kayıtlar `statu: 6`) → **Zamanlanmış Cloud Function** (bulk okuma) → **HTTP ile AI API** (OpenAI veya Vertex AI / Gemini) → **Realtime Database güncelleme** (`statu: 0` veya `7`).

- **15 dk iş:**  
  Mevcut **scheduledDistributeWinnings** benzeri bir fonksiyon: (1) İsteğe bağlı AI tutarlılık kontrolü, (2) Ardından mevcut dağıtım mantığı. AI çağrısı yine aynı Cloud Function içinde veya çağrılan bir HTTP/servis üzerinden yapılır.

- **Gizlilik / bölge:**  
  Veri Avrupa’da kalacaksa Vertex AI (EU bölgeleri) veya Azure OpenAI bölgesel endpoint’leri mimariye eklenebilir.

---

## 4. OpenRouter ile Yapay Kontroller (Seçilen Yol)

Yapay zeka kontrolleri **[OpenRouter](https://openrouter.ai/)** üzerinden yapılacak. OpenRouter, tek bir API ile birçok model sağlayıcıya (OpenAI, Anthropic, Google, vb.) erişim sağlar; fiyat ve erişilebilirlik avantajı sunar.

### 4.0 API Key’i Secret Manager ile Ekleme (Önerilen)

`functions.config()` Mart 2026’da kaldırılacak. OpenRouter API anahtarı **Secret Manager** ile saklanır.

**Adımlar:**

1. Proje kökünde terminal açın.
2. Secret’ı tanımlayın; komut key’i girmenizi isteyecek:
   ```bash
   firebase functions:secrets:set OPENROUTER_API_KEY
   ```
   OpenRouter’dan aldığınız anahtarı (örn. `sk-or-v1-...`) yapıştırıp Enter’a basın.
3. **(İsteğe bağlı)** Model için `functions/.env` dosyasına ekleyin: `OPENROUTER_MODEL=openai/gpt-4o-mini`
4. Deploy edin:
   ```bash
   firebase deploy --only functions
   ```

**Not:** Sadece `runAiModeration` bu secret’a bağlıdır (`secrets: ["OPENROUTER_API_KEY"]`). Detay: `functions/OPENROUTER_CONFIG.md`.

### 4.1 Neler Gerekli?

| Gereksinim | Açıklama |
|------------|----------|
| **Hesap** | [openrouter.ai](https://openrouter.ai/) üzerinden Google / GitHub / MetaMask ile kayıt. |
| **API anahtarı** | Dashboard’dan “API Keys” ile yeni anahtar oluşturulur. Bu anahtar, Cloud Functions’dan yapılacak HTTP isteklerinde `Authorization: Bearer <OPENROUTER_API_KEY>` olarak kullanılır. |
| **Anahtarın saklanması** | Geliştirmede API anahtarı **kod içine yazılmaz**. Firebase’de `firebase functions:config:set openrouter.api_key="..."` veya Firebase Environment Config / Secret Manager kullanılır; Cloud Function ortamında `functions.config().openrouter?.api_key` veya `process.env` ile okunur. |
| **Model seçimi** | OpenRouter’da “Models” sayfasından bir model seçilir (örn. `openai/gpt-4o`, `anthropic/claude-3-haiku`, `google/gemini-pro`). Çağrıda `model` alanına bu ID yazılır. Moderasyon için hızlı/ekonomik bir model yeterli olabilir. |
| **Endpoint** | Tüm chat/completion istekleri tek adrese gider: `https://openrouter.ai/api/v1/chat/completions`. API, **OpenAI uyumlu** olduğu için mevcut OpenAI SDK veya basit `fetch` ile aynı body formatı kullanılabilir. |

### 4.2 Mimariye Oturma

- **Gönderi moderasyonu (statu 6 → 0/7):**  
  **runAiModeration** HTTP fonksiyonu (şimdilik yalnızca manuel tetikleme) `statu = 6` kayıtlarını toplu okur. Her gönderi metni OpenRouter’a sistem prompt’u ile gönderilir; yanıt parse edilir → uygunsa `statu: 0`, değilse `statu: 7` ve gerekçe `aiModerationReason` alanında saklanır. İstenirse ileride aynı mantık 5 dk’da bir çalışan zamanlanmış bir fonksiyona taşınabilir.

- **15 dk’lık iş – tahmin tutarlılığı:**  
  Sonuçlanmış tahminler için OpenRouter’a “Bu sonuç, tahmin metni ile tutarlı mı?” benzeri bir prompt gönderilir. Gerekirse tutarsız kayıtlar işaretlenir; dağıtım mevcut kurallara göre devam eder.

- **Teknik taraf:**  
  Backend’de (Cloud Functions) sadece **HTTPS POST** ile `https://openrouter.ai/api/v1/chat/completions` çağrısı yapılır. Body: `{ "model": "openai/gpt-4o-mini", "messages": [ { "role": "system", "content": "..." }, { "role": "user", "content": "..." } ] }`. Header: `Authorization: Bearer <OPENROUTER_API_KEY>`, `HTTP-Referer` (opsiyonel, uygulama URL’i). Geliştirme yapılmadan burada kod yazılmaz; implementasyonda bu format kullanılır.

### 4.3 Özet Checklist (Geliştirme Öncesi)

1. OpenRouter’da hesap aç, API key al.  
2. API key’i Firebase config veya Secret Manager’da güvenli sakla.  
3. Kullanılacak modeli seç (moderasyon için örn. `openai/gpt-4o-mini` veya `anthropic/claude-3-haiku`).  
4. Cloud Function’da: `statu = 6` bulk okuma → her kayıt için OpenRouter `chat/completions` çağrısı → yanıta göre DB’de `statu` güncelleme.  
5. İsteğe bağlı: 15 dk işte sonuçlanmış tahminler için aynı endpoint ile tutarlılık kontrolü, ardından dağıtım.

Bu doküman sadece **mimari ve gereksinimleri** tanımlar; uygulama kodu burada yazılmaz.
