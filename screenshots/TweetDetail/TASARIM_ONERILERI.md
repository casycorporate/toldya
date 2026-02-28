# Tahmin Detayı (TweetDetail) – Tasarım Önerileri

Ekran görüntüleriyle karşılaştırıp geliştirme yapmadan önce uygulanabilecek tasarım iyileştirmeleri.

---

## 1. Ana sayfa kartı ile tutarlılık

- **Soru + countdown:** Ana akıştaki kartta kullanılan **büyük countdown (daire + kırmızı metin)** ve **EVET/HAYIR bar + tooltip (donut + “X Token bahis”)** detay sayfasında da kullanılabilir. Böylece aynı tahmin hem listede hem detayda aynı dilde görünür.
- **LIVE / Kapalı etiketi:** Üstte tek bir durum etiketi (LIVE, Kapanışa X kaldı, Kapandı) net olsun.

---

## 2. Bilgi hiyerarşisi

- **En üstte:** Tahmin sorusu (tek satır veya 2 satır, büyük punto).
- **Hemen altında:** Kullanıcı + kategori (Spor vb.) + kapanış/countdown; ikonlar küçük, metin okunaklı.
- **Oracle / Kapanış / Sonuç:** Bu üçü chip veya tek satır bilgi bandı olabilir; çok yer kaplamadan, aynı stil (ikon + label + değer).

---

## 3. EVET/HAYIR bölümü

- **Progress:** Ana sayfadaki gibi **tek yatay bar** (yeşil/kırmızı, yuvarlak uçlu), içinde “EVET %” / “HAYIR %” yazısı.
- **Hemen altında:** Küçük **tooltip/kutu** (donut + “X Token bahis”) ile toplam bahis miktarı.
- **Aksiyonlar:** İki seçenek:
  - **Seçenek A:** İki buton (Evet / Hayır) + ayrı “Bahis Yap” (miktar seçimi için).
  - **Seçenek B:** Tek “Bahis Yap” butonu; tıklanınca Evet/Hayır + miktar tek modal/sheet’te seçilsin (akış sadeleşir).

---

## 4. “Son bahisler” listesi

- **Görünüm:** Avatar + isim + miktar + Evet/Hayır etiketi; satırlar kompakt, aralıklar tutarlı.
- **Sıralama:** En yeni veya en yüksek bahis önce; kullanıcı tercihine bırakılabilir.
- **Boş durum:** “Henüz bahis yok” yerine kısa teşvik metni: “İlk bahsi sen yap” + “Bahis Yap” butonu.

---

## 5. Tartışma / Yorumlar

- **Başlık:** “Tartışma” veya “Yorumlar” net; gerekirse ikon (konuşma balonu).
- **Yorum kartları:** Ana kartla aynı radius ve gölge; avatar hizalı, metin okunaklı.
- **Boş durum:** “Henüz yorum yok. İlk yorumu sen yap” + yorum FAB veya inline buton.

---

## 6. Genel UI

- **Renk:** Dark tema ise arka plan, kart ve yazı renkleri ana sayfa/keşfet ile aynı paletten (örn. MockupDesign / AppColor).
- **Boşluklar:** Kart içi padding (16–20), bölümler arası (16–24) tutarlı olsun.
- **Butonlar:** Birincil aksiyon (Bahis Yap) belirgin; Evet/Hayır ikincil ama net ayrılsın (yeşil/kırmızı).
- **AppBar:** Geri + başlık (“Tahmin Detayı” veya sadece “Detay”) + paylaş; gereksiz aksiyon eklenmesin.

---

## 7. Özet uygulama sırası (geliştirme yaparken)

1. Countdown + EVET/HAYIR bar + tooltip’i ana karttaki widget’larla ortak kullan veya aynı görsel dili uygula.
2. Oracle/Kapanış/Sonuç alanını sadeleştir; tek satır veya 3 chip.
3. Bahis aksiyonunu tek “Bahis Yap” + modal veya iki buton (Evet/Hayır) + “Bahis Yap” olarak netleştir.
4. Son bahisler ve yorumlar bölümlerinde boş durum metinlerini güncelle.
5. Tüm ekranı dark/light tema ve ana sayfa ile aynı design token’larla (renk, radius, gölge) hizala.

Bu adımlar, `screenshots/TweetDetail` içine koyacağınız ekran görüntüleriyle karşılaştırılarak ince ayar yapılabilir.
