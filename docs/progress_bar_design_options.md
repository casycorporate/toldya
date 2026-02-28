# EVET / HAYIR Progress Bar – Tasarım Seçenekleri

Mevcut sorun: Yatay bar içinde yüzdeler segment genişliğine göre gösteriliyor; HAYIR oranı düşükken (örn. %18) "HAYIR 18%" metni kesiliyor veya okunaksız oluyor.

Aşağıda **4 farklı tasarım yaklaşımı** var. Birini seçersen, o seçeneğe göre `prediction_shared_ui.dart` güncellenebilir.

---

## Tasarım 1: Etiketler barın üstünde, yüzdeler barın altında

```
     EVET                    HAYIR
  ┌─────────────────────────────────────┐
  │█████████████████████│████            │  ← Sadece renk, metin yok
  └─────────────────────────────────────┘
      82%                      18%
```

- **Bar:** Sadece renk blokları (yeşil / kırmızı), içinde metin yok.
- **Üst satır:** Barın hemen üstünde, sola hizalı "EVET", sağa hizalı "HAYIR" (küçük font, opak).
- **Alt satır:** Barın hemen altında, yeşil segmentin ortasına "82%", kırmızı segmentin ortasına "18%" (küçük, bold).
- **Artı:** Yüzdeler her zaman tam görünür; dar segmentte bile kesilmez.
- **Eksi:** İki satır etiket kullanımı, biraz daha dikey yer kaplar.

---

## Tasarım 2: Bar tek renk, yüzdeler sağda tek satırda

```
  ┌─────────────────────────────────────┐
  │████████████████████████████████████  │  ← Tek renk (örn. yeşil veya nötr)
  └─────────────────────────────────────┘
  EVET 82%  ·  HAYIR 18%  ·  112 Token bahis
```

- **Bar:** Tek renk (veya çok hafif gradient), oranı sadece “doluluk” ile gösterir (soldan %82 dolu).
- **Altında tek satır:** "EVET 82% · HAYIR 18% · 112 Token bahis" (aynı font, nokta ile ayrılmış).
- **Artı:** Hiç kesilme riski yok; yüzdeler ve token tek yerde, okunaklı.
- **Eksi:** EVET/HAYIR renk ayrımı bar üzerinde değil, sadece metin/ikonla.

---

## Tasarım 3: Bar üzerinde sadece oran çizgisi, metinler her zaman dışarıda

```
  EVET 82%                    HAYIR 18%
  ┌─────────────────────────────────────┐
  │█████████████████████║████            │  ← Çizgi = sınır, metin bar dışında
  └─────────────────────────────────────┘
  ● EVET   ● HAYIR   112 Token bahis
```

- **Bar:** İki renkli segment (yeşil / kırmızı), **içinde hiç yazı yok**.
- **Barın üstü:** Sol tarafta "EVET 82%", sağ tarafta "HAYIR 18%" (bar genişliğinin dışında, hizalı).
- **Alt kutu:** Mevcut tooltip kutusu (donut + EVET/HAYIR legend + Token bahis) aynen kalabilir veya sadeleştirilebilir.
- **Artı:** Yüzdeler dar segmentten bağımsız; bar sadece görsel oran gösterir.
- **Eksi:** Üst satır için ek dikey boşluk gerekir.

---

## Tasarım 4: Minimum genişlik + metin gizleme (akıllı bar)

```
  ┌─────────────────────────────────────┐
  │████████████ EVET 82% ████│HAYIR 18% │  ← Segment min 60px ise metin, değilse sadece %
  └─────────────────────────────────────┘
```

- **Mantık:** Her segment için minimum genişlik (örn. 56–64 px). Segment bu genişliğin altındaysa sadece "%18" göster (HAYIR/EVET’i kısalt veya ikonla değiştir); üstündeyse "HAYIR 18%" tam yaz.
- **Alternatif:** Dar segmentte yalnızca yüzde, geniş segmentte "EVET 82%" / "HAYIR 18%".
- **Artı:** Mevcut bar yerleşimine en yakın; sadece dar durumda metin kesilmez.
- **Eksi:** İki farklı görünüm (tam metin / kısaltılmış); kurallar biraz daha karmaşık.

---

## Özet tablo

| Seçenek | Yüzde kesilmesi | Yer kaplama | Görsel netlik | Uygulama |
|--------|------------------|-------------|----------------|----------|
| 1      | Yok              | Orta        | Yüksek         | Orta     |
| 2      | Yok              | Az          | Orta           | Kolay    |
| 3      | Yok              | Orta        | Yüksek         | Orta     |
| 4      | Yok (min width)  | Az          | İyi            | Orta     |

**Öneri:** Okunabilirlik öncelikliyse **Tasarım 1** veya **Tasarım 3**; en az yer ve en basit kod isteniyorsa **Tasarım 2**. Mevcut bar görünümünü korumak istiyorsan **Tasarım 4**.

Hangisini uygulayalım? (1, 2, 3 veya 4 yazman yeterli.)
