// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Toldya';

  @override
  String get login => 'Giriş';

  @override
  String get signUp => 'Kayıt ol';

  @override
  String get tagline => 'Tahminlerini paylaş, demiş mi dememiş mi gör.';

  @override
  String get signInToContinue => 'Devam etmek için giriş yapın';

  @override
  String get followers => 'Takipçiler';

  @override
  String get follower => 'Takipçi';

  @override
  String get following => 'Takipler';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingsAndPrivacy => 'Ayarlar ve gizlilik';

  @override
  String get logout => 'Çıkış';

  @override
  String get account => 'Hesap';

  @override
  String get privacyAndPolicy => 'Gizlilik ve güvenlik';

  @override
  String get language => 'Dil';

  @override
  String get followSuccess => 'Takip edildi';

  @override
  String get unfollowSuccess => 'Takipten çıkıldı';

  @override
  String get errorGeneric => 'İşlem yapılamadı. Lütfen tekrar deneyin.';

  @override
  String get pleaseEnterName => 'Lütfen isim giriniz';

  @override
  String get nameTooLong => 'İsim uzunluğu 27 karakteri geçemez';

  @override
  String get pleaseFillForm => 'Lütfen formu dikkatlice doldurunuz';

  @override
  String get passwordMismatch => 'Parola ve doğrulama parolası eşleşmedi';

  @override
  String get back => 'Geri';

  @override
  String get signUpNow => 'Hemen Kaydol';

  @override
  String get alreadyHaveAccount => 'Zaten bir hesabın var mı?';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get name => 'İsim';

  @override
  String get enterEmail => 'E-mail giriniz';

  @override
  String get enterPassword => 'Şifre giriniz';

  @override
  String get enterPasswordAgain => 'Tekrar şifre giriniz';

  @override
  String get pleaseEnterEmail => 'Lütfen e-posta adresini girin';

  @override
  String get pleaseEnterPassword => 'Lütfen şifrenizi giriniz';

  @override
  String get passwordMinLength => 'Şifre en az 8 karakter uzunluğunda olmalı';

  @override
  String get validEmailRequired => 'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get emailEmpty => 'E-posta alanı boş olamaz';

  @override
  String get forgotPassword => 'Şifreyi unuttum?';

  @override
  String get shared => 'Paylaşıldı.';

  @override
  String get postUnderReview =>
      'Gönderiniz incelemeye alındı. Onaylandığında akışta görünecektir.';

  @override
  String get commentAdded => 'Yorumunuz eklendi.';

  @override
  String get errorTryAgain => 'Bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get post => 'Gönderi';

  @override
  String get cancel => 'İptal';

  @override
  String get confirm => 'Onayla';

  @override
  String get continueAction => 'Devam';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get disputeRecorded => 'İtirazınız kaydedildi';

  @override
  String get predictionDeleted => 'Tahmin silindi.';

  @override
  String get errorDeleteFailed =>
      'Silinirken bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get userBlocked => 'Kullanıcı engellendi.';

  @override
  String get pleaseSelectBetAmount => 'Lütfen bahis miktarı seçin!';

  @override
  String maxBetTokens(String maxVal) {
    return 'Maksimum bahis: $maxVal token';
  }

  @override
  String get betOnOneSideOnly =>
      'Bu tahminde zaten diğer tarafa bahis yaptınız. Bir tahminde yalnızca tek tarafa (Evet veya Hayır) bahis yapabilirsiniz.';

  @override
  String get betPlaced => 'Bahis alındı.';

  @override
  String get confirmBet => 'Bahsi onayla';

  @override
  String confirmBetMessage(String amount) {
    return 'Bu tahmine $amount token ile bahis yapmak istediğinize emin misiniz?';
  }

  @override
  String get messageSent => 'Gönderildi';

  @override
  String get messageSendFailed => 'Gönderilemedi. Lütfen tekrar deneyin.';

  @override
  String get usernameRequired => 'Kullanıcı adı boş bırakılamaz';

  @override
  String usernameRules(int min, int max) {
    return 'Kullanıcı adı $min–$max karakter olmalı; sadece harf, rakam ve alt çizgi kullanılabilir.';
  }

  @override
  String get usernameTaken => 'Bu kullanıcı adı alınmış';

  @override
  String get errorCheckFailed => 'Kontrol sırasında bir hata oluştu';

  @override
  String get errorSaveFailed => 'Kaydedilirken bir hata oluştu';

  @override
  String get nameTooLongProfile => 'İsim uzunluğu 27 karakteri aşamaz';

  @override
  String get adsComingSoon => 'Reklam özelliği yakında eklenecek.';

  @override
  String tokensAdded(String amount) {
    return '+$amount token eklendi!';
  }

  @override
  String get purchaseComingSoon => 'Satın alma yakında eklenecek.';

  @override
  String get searchHint => 'Ara...';

  @override
  String get trendPredictions => 'Trend Tahminler';

  @override
  String get noPredictionsInCategory => 'Bu kategoride tahmin yok';

  @override
  String get recentSearches => 'Son Aramalar';

  @override
  String get liveSuggestions => 'Canlı Öneriler';

  @override
  String get noResults => 'Sonuç yok';

  @override
  String get predictions => 'Tahminler';

  @override
  String get people => 'Kişiler';

  @override
  String get user => 'Kullanıcı';

  @override
  String get usernameLabel => 'Kullanıcı adı';

  @override
  String get prediction => 'Tahmin';

  @override
  String get noPredictionResult => 'Tahmin sonucu yok';

  @override
  String get noPersonResult => 'Kişi sonucu yok';

  @override
  String get noPredictionOutcome => 'Tahmin sonucu yok';

  @override
  String get followingLabel => 'Takip ediliyor';

  @override
  String get follow => 'Takip Et';

  @override
  String get categoryFlow => 'Akış';

  @override
  String get categoryFavorite => 'Favori';

  @override
  String get categoryFollow => 'Takip';

  @override
  String get categorySports => 'Spor';

  @override
  String get categoryEconomy => 'Ekonomi';

  @override
  String get categoryEntertainment => 'Eğlence';

  @override
  String get categoryPolitics => 'Siyaset';

  @override
  String get aboutToldya => 'Toldya Hakkında';

  @override
  String get help => 'Yardım';

  @override
  String get legal => 'Yasal';

  @override
  String get developer => 'Geliştirici';

  @override
  String get newMessage => 'Yeni mesaj';

  @override
  String get messages => 'Mesajlar';

  @override
  String get predictors => 'Tahminciler';

  @override
  String get bettors => 'Bahisçiler';

  @override
  String get dataPreference => 'Veri tercihi';

  @override
  String get darkModeAppearance => 'Koyu mod görünümü';

  @override
  String get wifiOnly => 'Yalnızca Wi-Fi';

  @override
  String get tokenInsufficient => 'Token yetersiz';

  @override
  String get closedNoSelection => 'Kapandığı için seçim yapılamaz';

  @override
  String get thisTweetUnavailable => 'Bu gönderi kullanılamıyor';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get challengeLabel => 'Meydan oku: ';

  @override
  String get selectUser => 'Kullanıcı seç';

  @override
  String get challengePickTitle => 'Meydan oku: Kullanıcı seç';

  @override
  String get followingListEmpty =>
      'Kimseyi takip etmiyorsunuz. Önce takip listesine ekleyin.';

  @override
  String get followingListLoadingOrEmpty =>
      'Takip listeniz yükleniyor veya listede kullanıcı bulunamadı.';

  @override
  String get agree => 'Katılıyorum';

  @override
  String get disagree => 'Katılmıyorum';

  @override
  String get voteFailed => 'Oylama gönderilemedi.';

  @override
  String get comments => 'Yorumlar';

  @override
  String get noCommentsYet => 'Henüz yorum yok. İlk yorumu sen yap.';

  @override
  String get predictionDetail => 'Tahmin Detayı';

  @override
  String get leaderboardTitle => 'Liderlik Tablosu';

  @override
  String get weeklyLeague => 'Haftalık Lig';

  @override
  String get leagueNotCreatedYet =>
      'Bu haftanın lig grubu henüz oluşturulmadı.';

  @override
  String get leagueWillAppearWhenAssigned =>
      'Lig ataması yapıldığında burada görüneceksin.';

  @override
  String get tokenInsufficientForVote =>
      'Token yetersiz olduğu için seçim yapılamaz';

  @override
  String get betErrorGeneric => 'Bahis gönderilemedi.';

  @override
  String gmsError(String message) {
    return 'Google Play Services hatası: $message';
  }

  @override
  String get unknownError => 'Bilinmeyen hata';

  @override
  String errorWithMessage(String message) {
    return 'Hata: $message';
  }

  @override
  String get changesSaved => 'Değişiklikler kaydedildi';

  @override
  String get resetPasswordSent =>
      'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.';

  @override
  String get selectProfilePhoto => 'Profil fotoğrafı seç';

  @override
  String get selectCoverPhoto => 'Kapak fotoğrafı seç';

  @override
  String get appAvatars => 'Uygulama avatarları';

  @override
  String get appCovers => 'Uygulama kapakları';

  @override
  String get exampleUsername => 'Örn: kullanici_123';

  @override
  String get bio => 'Biyografi';

  @override
  String get location => 'Konum';

  @override
  String get birthDate => 'Doğum tarihi';

  @override
  String get save => 'Kaydet';

  @override
  String get sortUserList => 'Kullanıcı listesini sırala';

  @override
  String get updateNow => 'Şimdi Güncelle';

  @override
  String get alert => 'Uyarı';

  @override
  String get forIos => 'iOS için';

  @override
  String get forAndroid => 'Android için';

  @override
  String get iSayYes => 'dedim';

  @override
  String get iSayNo => 'demedim';

  @override
  String get votersList => 'Seçim yapanlar';

  @override
  String get noVotesYet => 'Bu gönderiye henüz seçim yapılmadı';

  @override
  String get voteListEmptySubtitle =>
      'Bir kullanıcı bu gönderi için seçim yaptığında kullanıcı listesi burada gösterilecektir.';

  @override
  String get commentFailed => 'Yorum eklenemedi. Lütfen tekrar deneyin.';

  @override
  String get loginRequired => 'Giriş yapmanız gerekiyor.';

  @override
  String get betTimeout => 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';

  @override
  String get gmsUpdateMessage =>
      'Google Play Services hatası. Lütfen cihazınızı yeniden başlatın veya Google Play Services\'i güncelleyin.';

  @override
  String featureComingSoon(String feature) {
    return '$feature yakında eklenecek.';
  }

  @override
  String get tokenEarnTitle => 'Token Kazan';

  @override
  String get watchAdTitle => 'Reklam İzle';

  @override
  String tokenEarnFreeSubtitle(String amount) {
    return '$amount Token ücretsiz';
  }

  @override
  String get watch => 'İzle';

  @override
  String get dailyBonusTitle => 'Günlük Bonus';

  @override
  String get claim => 'Al';

  @override
  String get tryAgainTomorrow => 'Yarın tekrar dene';

  @override
  String get tokenPacksTitle => 'Token Paketleri';

  @override
  String get mostPopular => 'En popüler';

  @override
  String get bestValue => 'En iyi değer';

  @override
  String get dataUsageTitle => 'Veri kullanımı';

  @override
  String get dataSaverHeader => 'Veri tasarrufu';

  @override
  String get dataSaverTitle => 'Veri tasarrufu';

  @override
  String get dataSaverSubtitle =>
      'Etkinleştirildiğinde video otomatik oynatılmaz ve daha düşük kaliteli görseller yüklenir. Bu, bu cihazdaki tüm hesaplar için veri kullanımını azaltır.';

  @override
  String get imagesHeader => 'Görseller';

  @override
  String get highQualityImagesTitle => 'Yüksek kaliteli görseller';

  @override
  String highQualityImagesSubtitle(String network) {
    return '$network\\n\\nYüksek kaliteli görsellerin ne zaman yükleneceğini seçin.';
  }

  @override
  String get videoHeader => 'Video';

  @override
  String get highQualityVideoTitle => 'Yüksek kaliteli video';

  @override
  String highQualityVideoSubtitle(String network) {
    return '$network\\n\\nEn yüksek kalitenin ne zaman oynatılacağını seçin.';
  }

  @override
  String get videoAutoplayTitle => 'Video otomatik oynatma';

  @override
  String videoAutoplaySubtitle(String network) {
    return '$network\\n\\nVideonun ne zaman otomatik oynatılacağını seçin.';
  }

  @override
  String get dataSyncHeader => 'Veri senkronizasyonu';

  @override
  String get syncDataTitle => 'Verileri senkronize et';

  @override
  String get syncIntervalTitle => 'Senkronizasyon aralığı';

  @override
  String get daily => 'Günlük';

  @override
  String get syncDataDescription =>
      'Toldya\'nın deneyiminizi geliştirmek için arka planda verileri senkronize etmesine izin verin.';

  @override
  String get mobileDataWifi => 'Mobil veri ve Wi‑Fi';

  @override
  String get never => 'Asla';

  @override
  String get dim => 'Kısık';

  @override
  String get lightOut => 'Karanlık';

  @override
  String get darkModeTitle => 'Koyu Mod';

  @override
  String get on => 'Açık';

  @override
  String get off => 'Kapalı';

  @override
  String get automaticAtSunset => 'Gün batımında otomatik';

  @override
  String get verifiedUserFirst => 'Önce doğrulanmış kullanıcılar';

  @override
  String get newestUserFirst => 'Önce en yeni kullanıcılar';

  @override
  String get oldestUserFirst => 'Önce en eski kullanıcılar';

  @override
  String get maxFollowerFirst => 'En çok takipçili kullanıcılar';

  @override
  String get alphabeticallySort => 'Alfabetik';

  @override
  String get displayAndSoundTitle => 'Görüntü ve ses';

  @override
  String get mediaHeader => 'Medya';

  @override
  String get mediaPreviewsTitle => 'Medya önizlemeleri';

  @override
  String get displayHeader => 'Görüntü';

  @override
  String get emojiTitle => 'Emoji';

  @override
  String get emojiSubtitle =>
      'Cihazınızın varsayılan seti yerine uygulama setini kullanın';

  @override
  String get soundHeader => 'Ses';

  @override
  String get soundEffectsTitle => 'Ses efektleri';

  @override
  String get webBrowserHeader => 'Web tarayıcısı';

  @override
  String get useInAppBrowserTitle => 'Uygulama içi tarayıcıyı kullan';

  @override
  String get useInAppBrowserSubtitle =>
      'Harici bağlantıları uygulama içi tarayıcıyla aç';

  @override
  String get accessibilityTitle => 'Erişilebilirlik';

  @override
  String get screenReaderHeader => 'Ekran okuyucu';

  @override
  String get pronounceHashtagTitle =>
      '# işaretini \"hashtag\" olarak telaffuz et';

  @override
  String get visionHeader => 'Görme';

  @override
  String get composeImageDescriptionsTitle => 'Görsel açıklaması yaz';

  @override
  String get composeImageDescriptionsSubtitle =>
      'Görme engelli kullanıcılar için görselleri açıklama özelliği ekler.';

  @override
  String get motionHeader => 'Hareket';

  @override
  String get reduceMotionTitle => 'Hareketi azalt';

  @override
  String get reduceMotionSubtitle =>
      'Canlı etkileşim sayıları dahil uygulama içi animasyonları azaltın.';

  @override
  String get accountTitle => 'Hesap';

  @override
  String get loginHeader => 'Giriş';

  @override
  String get emailAddressTitle => 'E-posta adresi';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get filtersHeader => 'Filtreler';

  @override
  String get qualityFilterTitle => 'Kalite filtresi';

  @override
  String get qualityFilterSubtitle =>
      'Düşük kaliteli bildirimleri filtreleyin. Takip ettiğiniz kişilerden veya son zamanlarda etkileşimde bulunduğunuz hesaplardan gelen bildirimleri filtrelemez.';

  @override
  String get advancedFilterTitle => 'Gelişmiş filtre';

  @override
  String get mutedWordTitle => 'Sessize alınan kelimeler';

  @override
  String get preferencesHeader => 'Tercihler';

  @override
  String get unreadBadgeTitle => 'Okunmamış bildirim rozeti';

  @override
  String get unreadBadgeSubtitle =>
      'Uygulama içinde sizi bekleyen bildirim sayısını rozet olarak gösterin.';

  @override
  String get pushNotificationsTitle => 'Anlık bildirimler';

  @override
  String get smsNotificationsTitle => 'SMS bildirimleri';

  @override
  String get emailNotificationsTitle => 'E-posta bildirimleri';

  @override
  String get emailNotificationsSubtitle =>
      'Uygulamanın size ne zaman ve ne sıklıkla e-posta göndereceğini kontrol edin.';

  @override
  String get contentPreferencesTitle => 'İçerik tercihleri';

  @override
  String get exploreHeader => 'Keşfet';

  @override
  String get trendsTitle => 'Trendler';

  @override
  String get searchSettingsTitle => 'Arama ayarları';

  @override
  String get languagesHeader => 'Diller';

  @override
  String get recommendationsTitle => 'Öneriler';

  @override
  String get recommendationsSubtitle =>
      'Önerilen gönderilerin, kişilerin ve trendlerin hangi dilleri içereceğini seçin';

  @override
  String get safetyHeader => 'Güvenlik';

  @override
  String get blockedAccountsTitle => 'Engellenen hesaplar';

  @override
  String get mutedAccountsTitle => 'Sessize alınan hesaplar';

  @override
  String get helpHeader => 'Yardım';

  @override
  String get helpCenterTitle => 'Yardım merkezi';

  @override
  String get termsOfServiceTitle => 'Kullanım şartları';

  @override
  String get privacyPolicyTitle => 'Gizlilik politikası';

  @override
  String get cookieUseTitle => 'Çerez kullanımı';

  @override
  String get legalNoticesTitle => 'Yasal bildirimler';

  @override
  String get searchFilterTitle => 'Arama filtresi';

  @override
  String get trendsLocationTitle => 'Trend konumu';

  @override
  String get emailVerificationSent =>
      'Doğrulama bağlantısı e-posta adresinize gönderildi.';

  @override
  String get privacyAndSafetyTitle => 'Gizlilik ve güvenlik';

  @override
  String get privacySharesHeader => 'Paylaşımlar';

  @override
  String get protectPostsTitle => 'Paylaşımlarınızı koru';

  @override
  String get protectPostsSubtitle =>
      'Paylaşımlarınızı yalnızca mevcut takipçileriniz ve ileride onay vereceğiniz kişiler görebilir.';

  @override
  String get photoTaggingTitle => 'Fotoğraf etiketleme';

  @override
  String get photoTaggingSubtitle => 'Herkes sizi etiketleyebilir';

  @override
  String get liveVideoHeader => 'Canlı yayın';

  @override
  String get connectToLiveVideoTitle => 'Canlı yayına bağlan';

  @override
  String get connectToLiveVideoSubtitle =>
      'Açık olduğunda canlı yayın yapabilir ve yorum yapabilirsiniz; kapalı olduğunda diğerleri canlı yayın veya yorum yapamaz.';

  @override
  String get discoverabilityHeader => 'Keşfedilebilirlik ve kişiler';

  @override
  String get discoverabilityTitle => 'Keşfedilebilirlik ve kişiler';

  @override
  String get discoverabilitySubtitle =>
      'Bu verilerin sizi diğer kişilerle nasıl eşleştirmek için kullanıldığı hakkında daha fazla bilgi edinin.';

  @override
  String get securityHeader => 'Güvenlik';

  @override
  String get showSensitiveMediaTitle =>
      'Hassas içerik barındırabilecek medyayı göster';

  @override
  String get markSensitiveMediaTitle =>
      'Paylaştığınız medyayı hassas içerik barındırabilir olarak işaretle';

  @override
  String get mutedWordsTitle => 'Sessize alınan kelimeler';

  @override
  String get locationHeader => 'Konum';

  @override
  String get preciseLocationTitle => 'Tam konum';

  @override
  String get preciseLocationSubtitle =>
      'Kapalı\\n\\n\\nAçık olduğunda Toldya, cihazınızın tam konumunu (GPS bilgisi gibi) toplar, saklar ve kullanır. Bu sayede Toldya deneyiminizi iyileştirir; örneğin daha yerel içerik, reklam ve öneriler sunar.';

  @override
  String get personalizationHeader => 'Kişiselleştirme ve veri';

  @override
  String get personalizationTitle => 'Kişiselleştirme ve veri';

  @override
  String get allowAllSubtitle => 'Tümüne izin ver';

  @override
  String get viewYourDataTitle => 'Toldya verilerinizi görüntüle';

  @override
  String get viewYourDataSubtitle =>
      'Profil bilgilerinizi ve hesabınızla ilişkili verileri inceleyin ve düzenleyin.';

  @override
  String get proxyTitle => 'Proxy';

  @override
  String get enableHttpProxyTitle => 'HTTP Proxy\'yi etkinleştir';

  @override
  String get enableHttpProxySubtitle =>
      'Ağ istekleri için HTTP proxy yapılandırın (not: tarayıcı için geçerli değildir).';

  @override
  String get proxyHostTitle => 'Proxy sunucusu';

  @override
  String get proxyHostSubtitle => 'Proxy ana bilgisayar adını yapılandırın.';

  @override
  String get proxyPortTitle => 'Proxy portu';

  @override
  String get proxyPortSubtitle => 'Proxy port numarasını yapılandırın.';

  @override
  String get notificationsEmptyTitle => 'Henüz bildirim yok';

  @override
  String get notificationsEmptySubtitle =>
      'Yeni bildirim geldiğinde burada görünecek.';

  @override
  String votedOnYourPost(int count) {
    return '$count kişi paylaşımınıza oy verdi';
  }

  @override
  String get emailVerificationTitle => 'E-posta doğrulama';

  @override
  String get emailVerifiedTitle => 'E-posta adresiniz doğrulandı';

  @override
  String get emailVerifiedSubtitle => 'Mavi tiki aldınız. Tebrikler!';

  @override
  String get verifyEmailTitle => 'E-posta adresinizi doğrulayın';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Doğrulamak için $email adresine doğrulama bağlantısı gönderin.';
  }

  @override
  String get sendLink => 'Bağlantı gönder';

  @override
  String get noPredictorScoreYet => 'Henüz tahminci skoru yok';

  @override
  String get noBettorScoreYet => 'Henüz bahisçi skoru yok';

  @override
  String get followersTitle => 'Takipçiler';

  @override
  String noFollowersYet(String username) {
    return '$username hiç takipçisi yok';
  }

  @override
  String get followersWillAppearHere =>
      'Biri takip ettiğinde burada listelenir.';

  @override
  String get newMessageTitle => 'Yeni mesaj';

  @override
  String get searchPeopleOrGroupsHint => 'Kişi veya grup ara';

  @override
  String get googleSignInFailed => 'Google ile giriş yapılamadı.';

  @override
  String get googleSignInNotConfigured =>
      'Google girişi yapılandırılmamış. Firebase Console\'da uygulama SHA parmak izini ekleyin.';

  @override
  String get googleSignInButton => 'Google ile Bağlan';

  @override
  String get adminFilterLive => 'Devam eden';

  @override
  String get adminFilterPending => 'Bekleyen';

  @override
  String get adminFilterApproved => 'Onaylanan';

  @override
  String get adminFilterRejected => 'Reddedilen';

  @override
  String get adminFilterCompleted => 'Tamamlanan';

  @override
  String get adminFilterPendingAiReview => 'AI incelemesinde';

  @override
  String get adminFilterRejectedByAi => 'AI reddi';

  @override
  String xpProgressLabel(int xp, int max) {
    return '$xp / $max';
  }

  @override
  String xpProgressMaxLabel(int xp) {
    return '$xp (Usta)';
  }

  @override
  String get rankRookie => 'Çaylak';

  @override
  String get rankPredictor => 'Tahminci';

  @override
  String get rankMaster => 'Usta';

  @override
  String xpHintToBecomePredictor(int threshold) {
    return '$threshold XP\'de Tahminci olursun';
  }

  @override
  String xpHintToBecomeMaster(int threshold) {
    return '$threshold XP\'de Usta olursun';
  }

  @override
  String get xpHintMaxRank => 'Maksimum rütbedesin';

  @override
  String get rankProgressTitle => 'Rütbe ilerlemesi';

  @override
  String levelLabel(String level) {
    return 'Seviye $level';
  }

  @override
  String get noBetsYet => 'Henüz bahis yok.';

  @override
  String get noBetsYetHint =>
      'Yukarıdaki \"Evet ile bahis yap\" veya \"Hayır ile bahis yap\" butonuna tıklayarak bahis yapabilirsiniz.';

  @override
  String get dailyBonusClaimed => 'Günlük bonus alındı.';

  @override
  String get copyLink => 'Bağlantıyı kopyala';

  @override
  String get copiedToClipboard => 'Panoya kopyalandı';

  @override
  String get postTitle => 'Gönderi';

  @override
  String sharedPostDescription(String displayName) {
    return '$displayName bir gönderi paylaştı';
  }

  @override
  String sharedPredictionDescription(String displayName) {
    return '$displayName Toldya uygulamasında bir toldya paylaştı.';
  }

  @override
  String get editBioHint => 'Biyografiyi güncellemek için profili düzenle';

  @override
  String get noBio => 'Biyografi yok';

  @override
  String get delete => 'Sil';

  @override
  String muteUser(String name) {
    return '$name sessize al';
  }

  @override
  String get muteConversation => 'Bu görüşmeyi sessize al';

  @override
  String get viewHiddenReplies => 'Gizli yanıtları görüntüle';

  @override
  String blockUser(String name) {
    return '$name engelle';
  }

  @override
  String unblockUser(String name) {
    return '$name engeli kaldır';
  }

  @override
  String get report => 'Rapor et';

  @override
  String get withdrawReport => 'Şikayeti geri al';

  @override
  String get sendForApproval => 'Onaya gönder';

  @override
  String get approve => 'Onayla';

  @override
  String get reject => 'Reddet';

  @override
  String get dispute => 'İtiraz et';

  @override
  String get disputed => 'İtiraz ettiniz';

  @override
  String get writeMessageHint => 'Mesaj yazın...';

  @override
  String get commentHint => 'Yorum yazın...';

  @override
  String get searchHintShort => 'Ara..';

  @override
  String get directMessagesTitle => 'Direkt mesajlar';

  @override
  String get share => 'Paylaş';

  @override
  String get shareImageLink => 'Görsel bağlantısını paylaş';

  @override
  String get openInBrowser => 'Tarayıcıda aç';

  @override
  String get newUpdateAvailable => 'Yeni güncelleme mevcut';

  @override
  String get unsupportedVersionMessage =>
      'Uygulamanın mevcut sürümü artık desteklenmiyor. Vermiş olabileceğimiz her türlü rahatsızlıktan dolayı özür dileriz.';

  @override
  String get seeLeaderboard => 'Liderlik tablosunda gör';

  @override
  String profileShareTitle(String name) {
    return '$name Toldya\'da';
  }

  @override
  String profileShareDescription(String name) {
    return '$name profilini incele';
  }

  @override
  String get trendsLocationSubtitle => 'New York';

  @override
  String get trendsLocationHint =>
      'Trendler sekmenizde hangi konumun görüneceğini seçerek belirli bir konumda nelerin trend olduğunu görebilirsiniz.';

  @override
  String get myBetsTab => 'Bahislerim';

  @override
  String get myVotesTab => 'Oy verdiklerim';

  @override
  String get defaultUserHandle => '@kullanıcı';

  @override
  String get youAreBlocked => 'Engellendin';

  @override
  String balanceToken(int count) {
    return 'Bakiye: $count Token';
  }

  @override
  String dailyBonusClaim(int amount) {
    return 'Günlük bonusu al (+$amount token)';
  }

  @override
  String get tokenManagement => 'Token Yönetimi';

  @override
  String get emptyActivePredictions => 'Aktif tahminin yok';

  @override
  String get emptyPendingPredictions => 'Bekleyen tahminin yok';

  @override
  String get emptyCompletedPredictions => 'Tamamlanan tahminin yok';

  @override
  String get emptyRejectedPredictions => 'Reddedilen tahminin yok';

  @override
  String get emptyLockedPredictions => 'Kilitli tahminin yok';

  @override
  String get emptyMyNoVotes => 'Hiç oy vermedin';

  @override
  String get emptyMyNoPosts => 'Hiç gönderi yok';

  @override
  String get emptyMyNoMedia => 'Hiç gönderi veya medya yok';

  @override
  String emptyOtherNoVotes(String name) {
    return '$name hiç oy vermedi';
  }

  @override
  String emptyOtherNoPosts(String name) {
    return '$name hiç gönderi yok';
  }

  @override
  String emptyOtherNoMedia(String name) {
    return '$name hiç gönderi veya medya yok';
  }

  @override
  String get filterActive => 'Aktif';

  @override
  String get filterPending => 'Bekleyen';

  @override
  String get filterCompleted => 'Tamamlanan';

  @override
  String get filterRejected => 'Reddedilen';

  @override
  String get filterLocked => 'Kilitli';

  @override
  String get addNow => 'Şimdi ekle';

  @override
  String get willShowHere => 'Burada gösterilecekler';

  @override
  String get topicGeneral => 'Genel';

  @override
  String yesPercent(int percent) {
    return 'Evet $percent';
  }

  @override
  String noPercent(int percent) {
    return 'Hayır $percent';
  }

  @override
  String get followingCountLabel => 'Takipler';

  @override
  String get tokenLabel => 'Token';

  @override
  String get bottomNavHome => 'Ana';

  @override
  String get bottomNavSearch => 'Arama';

  @override
  String get bottomNavNotifications => 'Bildirim';

  @override
  String get bottomNavProfile => 'Profil';
}
