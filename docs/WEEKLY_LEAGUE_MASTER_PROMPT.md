# Weekly Micro-League — Master Prompt (Cursor Composer / Agent)

Bu dosya, "Lig / Leaderboard" özelliğini Duolingo tarzı haftalık mikro-lig sistemine dönüştürmek için Cursor Composer (Agent modunda) kullanılacak ana prompttur. İlgili tüm adımlar ve teknik gereksinimler aşağıda toplanmıştır.

---

**Bağlam:** Toldya Flutter uygulaması — koyu tema (#1A1F2E), vurgu rengi #FF6B6B, glassmorphism (BorderRadius 28). State: Provider (AuthState, SearchState). Routing: named routes `lib/helper/routes.dart`; LeaderboardPage `/LeaderboardPage` ile CustomRoute. `.cursorrules` kurallarına uy: i18n AppLocalizations + ARB, hardcoded string yok; hatalar SnackBar; yazma işlemlerinde çift tetiklemeyi engelle.

**Hedef:** Statik "Lig" (Haftalık Lig) ekranını Duolingo tarzı haftalık mikro-lig ile değiştir: haftalık sıfırlama, 30 kişilik tier tabanlı ligler, yükselme/düşme bölgeleri, etkileyici pre-sezon boş durumu, premium UX (shimmer, PopScope, CustomScrollView/SliverAppBar, haptik, flutter_animate).

---

## PART 1 — Firebase Realtime DB şeması ve Cloud Functions

### 1.1 Şema (Firebase Realtime Database)

- **profile/{uid}:**
  - Mevcut: `xp`, `leagueWeekId`, `leagueGroupId`.
  - Eklenecek: `weeklyXp` (number, her Pazar sıfırlanır), `tier` (string: `"Bronze"` | `"Silver"` | `"Gold"` | `"Diamond"`). Tier, sıfırlama anında toplam `xp` ile hesaplanır (örn. 0–500 Bronze, 501–1500 Silver, 1501–3500 Gold, 3501+ Diamond). Eşik değerlerini kod yorumunda belgele.

- **leagues/config:**
  - `currentWeekId` (string, örn. "2025-W10")
  - `groupSize`: 30
  - `tierNames`: ["Bronze","Silver","Gold","Diamond"]
  - `weekEndsAt` (opsiyonel): Haftanın bittiği Pazar 23:59 ISO string (geri sayım için)

- **leagues/weeks/{weekId}/groups:**
  - Yapı: Her grup aynı tier’dan tam 30 kullanıcı. Gruplar `leagues/weeks/{weekId}/groups/{tier}_{groupIndex}` altında; her biri `{ "uid1": weeklyXpSnapshot, "uid2": ... }` formatında.

- **leagues/weeks/{weekId}/promotionDemotion** (opsiyonel):
  - İsterseniz her groupId için `{ promoted: [uid1,...], demoted: [uid2,...] }` saklayın; yoksa client’ta rank 1–5 = yükselen, 26–30 = düşen olarak türetilebilir.

### 1.2 Cloud Function: Haftalık sıfırlama (Pazar 23:59 zamanlanmış)

- Zamanlanmış Cloud Function ekleyin (örn. pubsub schedule `0 59 23 * * 0` — Pazar 23:59 UTC; Türkiye için gerekirse ayarlayın).
- İsim örn. `runWeeklyLeagueReset`.
- Adımlar:
  1. Tüm kullanıcılar için `profile/{uid}/weeklyXp = 0` yapın (batch/loop).
  2. Sonraki hafta `weekId` hesaplayın (örn. `getISOWeekId` ile sonraki hafta).
  3. Her tier (Bronze, Silver, Gold, Diamond) için:
     - `profile.tier === tier` olan tüm uid’leri alın.
     - Rastgele karıştırın (veya “random” spec’e uygun şekilde).
     - 30’luk parçalara bölün; her parça bir mikro-lig grubu.
     - `leagues/weeks/{weekId}/groups/{tier}_{groupIndex} = { uid: 0, ... }` yazın (başlangıçta weeklyXp 0).
     - Her uid için `profile/{uid}/leagueWeekId = weekId`, `profile/{uid}/leagueGroupId = "{tier}_{groupIndex}"` yazın.
  4. `leagues/config`: `currentWeekId = nextWeekId`, `weekEndsAt =` sonraki Pazar 23:59 ISO.
- Tier’ı gruplamadan önce her profile’da set edin (sıfırlama anında `profile.xp` ile aynı eşiklerden türetin).
- Test için `runWeeklyLeagueResetLogic` export edin; zamanlanmış fonksiyonu da export edin.

### 1.3 Yükselme / düşme (bir sonraki sıfırlamada uygulanır)

- Sonraki haftanın gruplarını oluştururken:
  - Her grupta hafta sonu weeklyXp’e göre **üst 5**: bir üst tier’a (veya Diamond ise aynı tier başka grup).
  - **Alt 5**: bir alt tier’a (veya Bronze ise aynı tier önceki grup).
  - **Ortadaki 20**: aynı tier/grupta kalır.
- Bunu aynı zamanlanmış fonksiyon içinde yapın: Hafta N+1 atamasında hafta N gruplarını okuyun, grup bazında üst 5 / alt 5 hesaplayın, sonra kullanıcıları yeni tier’lara (yükselen / aynı / düşen) göre atayıp tier içinde karıştırıp 30’luk gruplara bölün.

### 1.4 Hafta içi XP birikimi

- Uygulama veya mevcut mantık XP verdiğinde (örn. doğru tahmin, streak) `profile/{uid}/weeklyXp` artırılsın (transaction veya güvenlik kuralları). Cloud Functions’da XP verme yoksa callable ekleyin veya client weeklyXp yazarken doğrulama yapsın. Tercihen artış sunucu tarafında olsun.

---

## PART 2 — Flutter: Pre-Season (boş durum) widget

### 2.1 Widget: LeaguePreSeasonEmptyState

- Konum: `lib/page/profile/leaderboard/` veya `lib/widgets/` altında ayrı bir widget.
- **Ortadaki grafik:** Kilitli sandık, kapalı arena kapısı veya büyük animasyonlu saat (biri seçilsin; asset yoksa Lottie veya flutter_animate ile Icon, örn. `Icons.lock` veya `Icons.emoji_events` ile pulse/scale loop). Hafif animasyon tercih (örn. `.animate().fade().scale()` repeat).
- **Başlık:** AppLocalizations — ARB key örn. `leaguePreSeasonTitle` (TR: "Yeni Sezon İçin Nefesler Tutuldu! 🏆"), bold, beyaz (MockupDesign.textPrimary).
- **Alt başlık:** ARB key `leaguePreSeasonSubtitle` (TR: "Rakiplerin belirleniyor... Lig atamaları yapıldığında burada 30 kişilik grubunla kıyasıya bir mücadele başlayacak."), gri, 16sp (MockupDesign.textSecondary, fontSize 16).
- **Arka plan:** MockupDesign.background (#1A1F2E, .cursorrules). Padding MockupDesign.screenPadding ile uyumlu.
- `app_tr.arb`, `app_en.arb`, `app_de.arb` için key’leri ekleyin; `flutter gen-l10n` çalıştırın.

---

## PART 3 — Flutter: Active League View (liste + header + sticky satır)

### 3.1 Yapı

- `CustomScrollView` + `SliverAppBar` kullanın; kullanıcı 30 kişilik listeyi aşağı kaydırdıkça “lig header” küçülsün. Siyah ekran olmasın; scaffold `backgroundColor = MockupDesign.background` (#1A1F2E).

### 3.2 Üst header (SliverAppBar veya özel sliver)

- **Lig rozeti:** Mevcut tier (örn. Silver Shield) — asset veya Icon + LeagueConfig.tierNames / profile.tier. Accent veya AppNeon ile stillendir.
- **Hafta bitiş geri sayımı:** `leagues/config.weekEndsAt` (veya currentWeekId’den Pazar 23:59 hesapla). "X gün X saat" benzeri; Timer veya Stream ile dakikalık güncelleme. Geri sayım formatı için ARB key ekleyin.

### 3.3 30 kullanıcı listesi

- **Veri:** `fetchLeagueGroupForUser(currentUserId)` kullanın; dönen liste weeklyXp’e göre azalan sıralı olsun (backend `leagues/weeks/{weekId}/groups` içinde weeklyXp tutar; client sıralar). Model’de şu an `xpSnapshot` varsa weeklyXp için `weeklyXpSnapshot` ekleyin veya isim net olsun.
- **Üst 5 satır (sıra 1–5):** Hafif yeşil arka plan (örn. AppNeon.green.withOpacity(0.12)), küçük yeşil ⬆️ veya ok ikonu (yükselme bölgesi).
- **Alt 5 satır (sıra 26–30):** Hafif kırmızı arka plan (örn. AppNeon.red.withOpacity(0.12)), ⬇️ (düşme bölgesi).
- **Ortadaki 20:** Bölge arka planı yok.
- **Mevcut kullanıcı satırı:** Belirgin border (örn. 2px solid #FF6B6B). Kullanıcı scroll edip kendi satırı ekrandan çıkınca, viewport’un altında “pinned” bir satır gösterin (sıra, avatar, isim, weeklyXp). Scroll dinleyip kullanıcı satırı görünür alanın dışındayken bu tek pinned widget’ı gösterin.

### 3.4 Satıra tıklama

- Tıklamada `HapticFeedback.lightImpact()`. Profile git: `Navigator.pushNamed(context, '/ProfilePage/${user.userId}')`.

---

## PART 4 — Premium UX (mutlaka uygula)

### 4.1 Navigasyon

- LeaderboardPage scaffold’u `PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) { if (!didPop && Navigator.canPop(context)) Navigator.pop(context); })` ile sarın. Tab geçişleri için Navigator.push kullanmayın; LeaderboardPage push edilmiş bir route.

### 4.2 Yükleme

- Lig verisi yüklenirken (FutureBuilder beklerken veya userlist için state.isBusy) **CustomShimmer** ile skeleton liste gösterin. **LeagueShimmer:** _LeaderTile düzenine uyan 6–8 placeholder satır (avatar daire, iki satır metin, skor pill). Asla boş ekran veya tek CircularProgressIndicator göstermeyin. `lib/widgets/newWidget/custom_shimmer.dart` içindeki CustomShimmer base/highlight kullanın.

### 4.3 Scroll

- `CustomScrollView` + `SliverAppBar` (flexibleSpace’te lig rozeti + geri sayım). 30 satır için SliverList. Aşağı kaydırınca app bar’ın düzgünce küçülmesini sağlayın.

### 4.4 Haptik ve animasyon

- Her lig satırına tıklanınca: `HapticFeedback.lightImpact()`.
- 30 liste öğesi ilk yüklendiğinde flutter_animate ile animasyon: örn. `listItem.animate().fadeIn().slideY(begin: 0.1, end: 0).stagger(50.ms)`. Gecikme makul olsun.

---

## PART 5 — Mevcut Leaderboard sayfasına entegrasyon

### 5.1 Sekmeler

- Mevcut 3 sekme kalsın (Tahminciler, Bahisçiler, Haftalık Lig). Sadece üçüncü sekmenin (_LeagueTab) içeriği değişecek.

### 5.2 _LeagueTab mantığı

- Mevcut kullanıcının bu hafta lig ataması yoksa (`fetchLeagueGroupForUser` boş dönüyor veya profile.leagueWeekId != config.currentWeekId): **LeaguePreSeasonEmptyState** göster.
- Yükleme sırasında (userlist null veya lig fetch devam ediyor): **LeagueShimmer** (skeleton), CustomScreenLoader değil.
- Atama varsa: Yeni **ActiveLeagueView** (CustomScrollView + header + 30 satır bölgeler + pinned kullanıcı satırı).

### 5.3 Veri bağımlılığı

- SearchState.getDataFromDatabase() çağrılmaya devam etsin (isim ve avatar için userlist). Lig verisi fetchLeagueGroupForUser ve leagues/config’ten gelsin. LeagueState (Provider) eklerseniz minimal tutun; sadece league/config + kullanıcının grubu; kullanıcı detayı SearchState’ten kalabilir.

---

## PART 6 — Dokunulacak dosyalar (kontrol listesi)

| Alan | Dosya / işlem |
|------|----------------|
| Backend | `functions/index.js`: runWeeklyLeagueReset (zamanlanmış), runWeeklyLeagueResetLogic, tier türetme, weeklyXp sıfırlama, tier’a göre grup atama, yükselme/düşme; isteğe leagues/config’e weekEndsAt. |
| Model | `lib/model/league.dart`: LeagueEntry’de weeklyXpSnapshot (veya xpSnapshot’ı haftalık olarak kullan); LeagueConfig’e weekEndsAt. |
| Model | `lib/model/user.dart`: Gerekirse profile’dan okunan weeklyXp ve tier ekle. |
| UI | `lib/page/profile/leaderboard/leaderboardPage.dart`: PopScope sarma; _LeagueTab gövdesini LeagueShimmer / LeaguePreSeasonEmptyState / ActiveLeagueView ile değiştir; ActiveLeagueView’da CustomScrollView + SliverAppBar; yeşil/kırmızı bölgeler, kullanıcı border, pinned satır, HapticFeedback, liste öğesi flutter_animate. |
| Shimmer | `lib/widgets/newWidget/custom_shimmer.dart` (veya yeni dosya): LeagueShimmer widget. |
| Boş durum | Yeni widget: LeaguePreSeasonEmptyState (başlık, alt başlık, ortada grafik + isteğe animasyon). |
| i18n | `lib/l10n/app_tr.arb`, `app_en.arb`, `app_de.arb`: leaguePreSeasonTitle, leaguePreSeasonSubtitle, gerekirse geri sayım formatı; `flutter gen-l10n`. |
| Kurallar | .cursorrules: #1A1F2E ve #FF6B6B zaten var; lig için ek kural istemezseniz değişiklik yok. |

**Uygulama sırası:** Önce şema + Cloud Function, sonra pre-season widget ve i18n, ardından ActiveLeagueView ve shimmer, en sonda PopScope ile animasyon/haptik.
