# Ben Demiştim – Tüm Ekranlar İçin UI Yeniden Tasarım Promptları

Bu dokümanda, projeyi **değişiklik yapmadan** sadece tasarım fikri olarak yeniden kurgulamak için bir **UI/UX tasarım yapay zekasına** (ör. v0.dev, Galileo, Uizard, Figma AI veya metin tabanlı bir tasarım asistanına) verebileceğin prompt örnekleri var. Amaç: **güncel, minimalist** bir uygulama görünümü için tutarlı brief ve ekran bazlı promptlarla daha iyi sonuç almak.

---

## Kısa proje özeti (AI’a her zaman ekle)

Aşağıdaki paragrafı promptların başına veya “context” alanına ekle:

```
Uygulama: "Ben Demiştim" – mobil öncelikli sosyal tahmin/bahis uygulaması (Flutter).
Kullanıcılar tahmin metni paylaşır (örn. "Galatasaray şampiyon olur"); diğerleri EVET/HAYIR ile token ile bahis yapar.
Kategoriler: Spor, Ekonomi, Eğlence, Siyaset. Dark mode öncelikli; light mode da destekleniyor.
Hedef: Güncel, minimalist, temiz arayüz; gereksiz süsleme yok; okunabilirlik ve hız ön planda.
```

---

## Genel tasarım brief’i (ilk prompt)

Bunu ilk sırada ver; tüm ekranlar bu kurallara göre tasarlanacak:

```
Bu mobil uygulama için global UI kurallarını belirle:

1. Stil: Minimalist, 2024–2025 dönemi mobil best practice. Fazla gölge ve gradient yok; flat veya çok hafif depth.
2. Renk: Dark theme varsayılan. Arka plan koyu gri/mavi ton (#1C1C1E benzeri). Birincil aksan tek renk (örn. yeşil veya turuncu); EVET için yeşil, HAYIR için kırmızı korunacak.
3. Tipografi: Başlıklar için tek sans-serif ailesi; gövde metni okunaklı, yeterli kontrast. Türkçe karakterler düşünülmüş.
4. Boşluk: Bol padding ve tutarlı spacing (8px grid); kartlar arası mesafe net.
5. Bileşenler: Yuvarlatılmış köşeler (8–16px); butonlar belirgin ama sade; bottom navigation ortada FAB ile çentikli bar.
6. İkonlar: Outline veya tek ağırlık; tutarlı stroke kalınlığı.
7. Erişilebilirlik: Touch target en az 44pt; metin kontrast oranları WCAG AA.

Bu kuralları "Ben Demiştim" adlı sosyal tahmin uygulaması için bir Design System özeti olarak çıkar (renk paleti, spacing, tipografi, bileşen stilleri). Ekran listesini henüz çizme.
```

---

## Ekran listesi (referans)

Tasarım AI’ına “hangi ekranlar var” diye verirken kullan:

| # | Ekran | Açıklama |
|---|--------|----------|
| 1 | Ana sayfa (Home) | Alt tab bar (Ana, Arama, Bildirim, Profil) + ortada FAB (yeni tahmin). Üstte başlık "Ben demiştim", menü, ikonlar. |
| 2 | Akış (Feed) | Sekmeler: Akış, Favori, Takip, Spor, Ekonomi. Tahmin kartları listesi (başlık, kullanıcı, kategori, LIVE/Bitti, countdown, EVET/HAYIR bar, Token bahis, BAHIS YAP). |
| 3 | Tahmin kartı (kart bileşeni) | Tek bir tahmin: başlık, avatar+kullanıcı+kategori, durum (LIVE/Bitti), süre, EVET/HAYIR progress bar, Token bahis bilgisi, buton. |
| 4 | Tahmin detay | Tek tahminin tam sayfası: tüm bilgiler, Evet/Hayır ile bahis yap butonları, son bahisler listesi, kapanış/sonuç tarihi. |
| 5 | Tahmin oluştur (Compose) | Metin alanı (tahmin metni), kategori seçimi, gönder butonu. |
| 6 | Arama (Search) | Arama çubuğu, son aramalar / öneriler, arama sonuçları. |
| 7 | Bildirimler | Bildirim listesi (takip, bahis, sonuç vb.). |
| 8 | Profil | Avatar, kullanıcı adı, token/bakiye, Bahislerim (Aktif/Bekleyen/Tamamlanan/Reddedilen), takipçi/takip, ayarlar. |
| 9 | Profil düzenle | Foto, isim, bio vb. alanlar. |
| 10 | Bahislerim (profil içi) | Filtreler: Aktif, Bekleyen, Tamamlanan, Reddedilen; bahis kartları listesi. |
| 11 | Token kazan | Token nasıl kazanılır / bilgi ekranı. |
| 12 | Liderlik tablosu | Sıralama listesi. |
| 13 | Takipçi / Takip listeleri | Kullanıcı listesi. |
| 14 | Mesajlar (liste) | Sohbet listesi. |
| 15 | Sohbet ekranı | Mesaj balonları, giriş alanı, karşı taraf bilgisi. |
| 16 | Yeni mesaj | Kullanıcı seçimi, sohbet başlatma. |
| 17 | Resim görüntüleme | Tam ekran resim. |
| 18 | Ayarlar ana | Hesap, bildirimler, görünüm, veri, gizlilik, proxy vb. menü öğeleri. |
| 19 | Alt ayar sayfaları | Bildirim, görünüm/ses, veri kullanımı, proxy, gizlilik, trendler vb. |
| 20 | Kullanıcı listesi (genel) | Arama sonucu veya takip önerisi kullanıcı listesi. |
| 21 | Splash / giriş | Logo, uygulama adı; gerekirse giriş/kayıt yönlendirmesi. |
| 22 | Şifremi unuttum | E-posta alanı, sıfırlama butonu. |
| 23 | Loader / boş durum | Yükleme göstergesi; liste boşken kısa mesaj ve aksiyon. |

---

## Ekran bazlı prompt örnekleri

Her ekran için **tek tek** veya **gruplar halinde** aşağıdaki gibi prompt verebilirsin. “Genel tasarım brief’i”ni ve “proje özeti”ni üstte verdiğini varsay.

### 1) Ana iskelet ve navigasyon

```
Ekran: Ana sayfa. Altında 4 sekmeli bottom navigation (Ana, Arama, Bildirim, Profil). Ortada yüksük (notch) ile FAB. Üstte AppBar: sol menü, ortada "Ben demiştim", sağda 1–2 ikon. İçerik alanı Feed. Güncel minimalist stil; dark theme. Wireframe veya low-fi ekran çiz.
```

### 2) Feed ve tahmin kartı

```
Ekran: Tahmin akışı. Üstte sekme çubuğu: Akış, Favori, Takip, Spor, Ekonomi. Altında tahmin kartları: her kartta başlık (tahmin metni), kullanıcı avatar + ad + kategori, LIVE/Bitti etiketi, kalan süre, yatay EVET/HAYIR progress bar (yeşil/kırmızı), "X Token bahis" satırı, BAHIS YAP butonu. Minimalist kart; gölge hafif; padding bol. Bir kart için component spec veya ekran taslağı çiz.
```

### 3) Tahmin detay

```
Ekran: Tek tahmin detay sayfası. Üstte geri + başlık. Tahmin metni, kullanıcı bilgisi, kapanış/sonuç tarihi. EVET/HAYIR oran barı. İki büyük aksiyon: "Evet ile bahis yap" ve "Hayır ile bahis yap". Altında "Son bahisler" listesi. Minimalist; dark theme. Layout taslağı ver.
```

### 4) Tahmin oluşturma

```
Ekran: Yeni tahmin oluştur. Büyük metin alanı (placeholder: tahminini yaz), kategori seçici (Spor, Ekonomi, Eğlence, Siyaset), gönder butonu. Sade; gereksiz alan yok. Tek ekran taslağı.
```

### 5) Profil ve Bahislerim

```
Ekran: Kullanıcı profili. Üstte avatar, isim, token/bakiye. Sekmeler veya filtreler: Bahislerim (Aktif, Bekleyen, Tamamlanan, Reddedilen). Altında ilgili bahis kartları. Ayarlar girişi. Minimalist profil sayfası; dark theme.
```

### 6) Mesajlar ve sohbet

```
Ekran 1: Sohbet listesi. Başlık "Mesajlar", arama veya filtre (isteğe bağlı). Liste: her satırda avatar, kullanıcı adı, son mesaj önizlemesi, zaman. Minimalist liste.
Ekran 2: Sohbet ekranı. Üstte karşı kullanıcı bilgisi. Mesaj balonları (gönderen/alıcı ayrımı). Altta metin girişi + gönder. Sade mesajlaşma UI’ı.
```

### 7) Arama ve bildirim

```
Ekran 1: Arama. Üstte arama çubuğu. Son aramalar veya öneriler. Sonuçlar: kullanıcı veya tahmin kartı özeti. Minimalist arama sayfası.
Ekran 2: Bildirimler. Başlık "Bildirimler". Liste: ikon, başlık, kısa metin, zaman. Okunmamış vurgusu. Dark theme.
```

### 8) Ayarlar

```
Ekran: Ayarlar ana menü. Gruplar: Hesap, Bildirimler, Görünüm ve ses, Veri, Gizlilik, Proxy vb. Her satır: ikon + başlık + sağda ok veya toggle. Minimalist ayar listesi; dark theme.
```

### 9) Ortak bileşenler

```
Bileşen seti (minimalist, dark theme):
- Birincil buton (dolu, tek renk)
- İkincil buton (outline veya ghost)
- Kart (rounded, hafif border veya gölge)
- Liste satırı (avatar + 2 satır metin + aksiyon)
- Progress bar (EVET yeşil / HAYIR kırmızı, yuvarlak uç)
- Bottom nav + FAB (çentikli)
- AppBar (transparent veya dolu, tek renk)
Bunları tek bir design system sayfasında topla; renk ve spacing değerleriyle.
```

---

## Daha iyi sonuç için ipuçları

1. **Önce genel brief, sonra ekran:** Önce “Genel tasarım brief’i”ni verip renk/spacing/typography kurallarını çıkart; sonra ekran ekran “bu kurallara uygun çiz” de.
2. **Tek ekran, tek prompt:** Her seferinde 1–2 ekran iste; “tüm uygulamayı çiz” demek yerine parça parça isteyip tutarlılığı sen birleştirirsin.
3. **Referans ekle:** “Material 3 veya iOS Human Interface Guidelines’a yakın; ama daha az kalabalık” gibi bir cümle ekle.
4. **Çıktı formatı belirt:** “Figma için”, “Flutter widget ağacı için açıklama olarak”, “HTML/CSS için” gibi net söyle.
5. **Dil:** Promptları Türkçe yazabilirsin; “Respond in Turkish” dersen tasarım açıklamaları da Türkçe gelir.

---

## Özet: Sırayla ne vereceksin?

1. **Proje özeti** (en üstteki kutu) + **Genel tasarım brief’i** (ilk uzun prompt).  
2. **Ekran listesi** (tablo) – “Bu uygulamada bu ekranlar var.”  
3. **Ekran bazlı promptlar** – İstediğin ekranları yukarıdaki gibi tek tek veya 2’li 3’lü gruplar halinde ver.  
4. **Ortak bileşenler** promptu – Tüm ekranlarda kullanılacak buton, kart, bar stillerini tek seferde tanımlat.

Bu sıra ve metinler, tasarım AI’ının tutarlı ve minimalist bir “Ben Demiştim” UI seti üretmesine yardımcı olur. İstersen bir sonraki adımda bu promptlardan biri için örnek bir “AI’dan gelen yanıt” senaryosu da yazabilirim (uygulama kodu değişmeden, sadece tasarım çıktısı olarak).
