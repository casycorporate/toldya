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
  String get retoldyaSubmitButton => 'Retoldya';

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
  String get adminModeration => 'Admin Moderasyon';

  @override
  String get adminJobsTitle => 'Admin İşleri';

  @override
  String get adminSegmentModeration => 'Moderasyon';

  @override
  String get adminSegmentResolve => 'Sonuçlandır';

  @override
  String get adminSegmentQuickFix => 'Hızlı Düzeltme';

  @override
  String get adminSegmentDistribute => 'Dağıtım';

  @override
  String get adminJobSecretLabel => 'Job Secret';

  @override
  String get adminJobSecretHint => 'Secret girin';

  @override
  String get adminJobSecretSessionNote =>
      'Sadece bu oturumda bellekte tutulur.';

  @override
  String get adminJobSecretMissing => 'Devam etmek için job secret gerekli.';

  @override
  String get adminResolveTitle => 'Sonuçlandır';

  @override
  String get adminResolveDesc =>
      'Vadesi geçmiş ve henüz sonuçlandırılmamış tahminleri listeler. Admin olarak Evet/Hayır sonucunu seçip manuel sonuçlandırabilirsiniz.';

  @override
  String get adminResolvePreviewButton => 'Önizle';

  @override
  String get adminResolveRunButton => 'Çalıştır';

  @override
  String get adminResolveManualYes => 'Evet kazandı';

  @override
  String get adminResolveManualNo => 'Hayır kazandı';

  @override
  String get adminResolveManualApply => 'Sonuçlandır';

  @override
  String get adminResolveManualSuccess => 'Tahmin sonuçlandırıldı.';

  @override
  String get adminDistributeTitle => 'Dağıtım';

  @override
  String get adminDistributeDesc =>
      'Sonuçlanan tahminlerin kazançlarını tek tek dağıtabilirsiniz.';

  @override
  String get adminDistributeIdempotentNote =>
      'Not: Bu işlem idempotent çalışır.';

  @override
  String get adminDistributePreviewButton => 'Önizle';

  @override
  String get adminDistributeRunButton => 'Çalıştır';

  @override
  String get adminDistributeManualApply => 'Kazancı dağıt';

  @override
  String get adminDistributeManualSuccess => 'Kazanç dağıtıldı.';

  @override
  String get adminDistributeManualNoop => 'Dağıtılacak kazanç bulunamadı.';

  @override
  String get adminQuickFixTitle => 'Hızlı Düzeltme';

  @override
  String get adminQuickFixDesc =>
      'statu=1 olup tarih alanları eksik/bozuk olan kayıtları düzeltir. Tarihleri ayarlayıp isterseniz yayına alarak normal kilitleme → oracle → dağıtım akışını başlatabilirsiniz.';

  @override
  String adminQuickFixCount(String n) {
    return 'Eksik tarihli kayıtlar: $n';
  }

  @override
  String get adminQuickFixSearchHint => 'ID veya açıklamada ara';

  @override
  String get adminQuickFixFilterEndDatePassed =>
      'Sadece endDate geçmiş olanlar';

  @override
  String get adminQuickFixEndDateLabel => 'End date';

  @override
  String get adminQuickFixResolutionDateLabel => 'Resolution date';

  @override
  String get adminQuickFixAutofillEndNowPlus => 'EndDate = şimdi + 5dk';

  @override
  String get adminQuickFixAutofillResolutionPlus1h =>
      'ResolutionDate = endDate + 1s';

  @override
  String get adminQuickFixSetOnly => 'Sadece ayarla';

  @override
  String get adminQuickFixSetAndPublish => 'Ayarla ve yayına al';

  @override
  String get adminQuickFixConfirmPublish => 'Yayına almayı onaylıyorum';

  @override
  String get adminQuickFixValidationEndRequired => 'EndDate gerekli.';

  @override
  String get adminQuickFixValidationResolutionRequired =>
      'ResolutionDate gerekli.';

  @override
  String get adminQuickFixValidationResolutionAfterEnd =>
      'ResolutionDate, EndDate\'ten sonra olmalı.';

  @override
  String get adminQuickFixValidationMin1h =>
      'ResolutionDate, EndDate\'ten en az 1 saat sonra olmalı.';

  @override
  String get adminQuickFixSuccess => 'Kayıt güncellendi.';

  @override
  String get adminQuickFixWarningPublish =>
      'Bu işlem tahmini yayına alır ve lock/oracle job\'ları ile otomatik ilerler.';

  @override
  String adminQuickFixCreatedAt(String t) {
    return 'Oluşturma: $t';
  }

  @override
  String get adminQuickFixChipStatu1 => 'statu: 1';

  @override
  String get adminQuickFixChipEndMissing => 'endDate: eksik';

  @override
  String get adminQuickFixChipEndInvalid => 'endDate: geçersiz';

  @override
  String get adminQuickFixChipEndOk => 'endDate: ok';

  @override
  String get adminQuickFixChipEndPassed => 'endDate: geçti';

  @override
  String get adminQuickFixChipResMissing => 'resolutionDate: eksik';

  @override
  String get adminQuickFixChipResInvalid => 'resolutionDate: geçersiz';

  @override
  String get adminQuickFixChipTopicMissing => 'topic: eksik';

  @override
  String adminDistributeTotalPoolEstimate(String n) {
    return 'Toplam havuz tahmini: $n';
  }

  @override
  String adminPreviewCandidates(String n) {
    return 'Aday sayısı: $n';
  }

  @override
  String adminJobResultResolved(String n) {
    return 'Sonuçlandırıldı: $n';
  }

  @override
  String adminJobResultDistributed(String n) {
    return 'Dağıtıldı: $n';
  }

  @override
  String get adminJobSkippedTitle => 'Atlananlar';

  @override
  String get adminJobShowMore => 'Daha fazla göster';

  @override
  String get adminJobShowLess => 'Daha az göster';

  @override
  String adminJobErrorWithMessage(String msg) {
    return 'Hata: $msg';
  }

  @override
  String get adminModerationQueueEmpty => 'Bekleyen moderasyon yok.';

  @override
  String get adminModerationReject => 'Reddet';

  @override
  String get adminModerationRejectReasonHint => 'Reddetme gerekçesi';

  @override
  String get adminModerationApprove => 'Onayla';

  @override
  String get adminModerationApproveTitle => 'Yayına al';

  @override
  String get adminModerationTopicLabel => 'Kategori';

  @override
  String get adminModerationEndDateLabel => 'Kapanış';

  @override
  String get adminModerationResolutionDateLabel => 'Sonuç zamanı';

  @override
  String get adminModerationOracleSourceOptional =>
      'Oracle kaynağı (opsiyonel)';

  @override
  String get adminModerationOracleApiUrlOptional =>
      'Oracle API URL (opsiyonel)';

  @override
  String get adminModerationCollateralOptional => 'Teminat (opsiyonel)';

  @override
  String get adminModerationInvalidForm => 'Lütfen gerekli alanları doldurun.';

  @override
  String get adminModerationDateRule =>
      'Sonuç zamanı kapanıştan en az 1 saat sonra olmalı.';

  @override
  String get adminModerationConflictRetry => 'Çakışma oldu, tekrar deneyin.';

  @override
  String get adminModerationActionFailed => 'İşlem başarısız.';

  @override
  String get adminModerationMetaUser => 'Kullanıcı';

  @override
  String get adminModerationMetaCreatedAt => 'Oluşturma';

  @override
  String get adminModerationMetaTopic => 'Konu';

  @override
  String get adminModerationMetaOracleApiUrl => 'Oracle URL';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingsAndPrivacy => 'Ayarlar ve gizlilik';

  @override
  String get drawerActivePredictions => 'Aktif Tahminlerim';

  @override
  String get drawerWeeklyLeague => 'Haftalık Lig';

  @override
  String get drawerSettingsAndPrivacy => 'Ayarlar ve Gizlilik';

  @override
  String get drawerWalletTitle => 'Puan';

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
  String get pressBackAgainToExit => 'Çıkmak için tekrar geri tuşuna basın';

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
  String get retry => 'Tekrar dene';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get endOfResults => 'Sonuçların sonu';

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
  String get userUnblocked => 'Engel kaldırıldı.';

  @override
  String get pleaseSelectStakeAmount => 'Lütfen tahmin puanını seçin!';

  @override
  String maxStakeTokens(String maxVal) {
    return 'Maksimum tahmin: $maxVal puan';
  }

  @override
  String get stakeOneSideOnly =>
      'Bu tahminde zaten diğer tarafı seçtiniz. Bir tahminde yalnızca tek tarafı (Evet veya Hayır) seçebilirsiniz.';

  @override
  String get stakePleaseWait => 'Tahmin işlemi sürüyor, lütfen bekleyin.';

  @override
  String get stakeLimitHint =>
      'Maksimum tahmin puanı bakiye, rütbe ve toplam tahmin sayısına göre belirlenir.';

  @override
  String availableBalanceTokens(String pegCount) {
    return 'Kullanılabilir puan: $pegCount 🪙';
  }

  @override
  String get stakeSheetSideYes => 'Evet';

  @override
  String get stakeSheetSideNo => 'Hayır';

  @override
  String get stakeSheetSubmitYes => 'EVETİ SEÇ';

  @override
  String get stakeSheetSubmitNo => 'HAYIRI SEÇ';

  @override
  String potentialReturnEstimate(String amount) {
    return 'Olası skor: ~$amount 🪙';
  }

  @override
  String get potentialReturnUnavailable => '—';

  @override
  String get potentialReturnDisclaimer => 'Yaklaşık tahmin; garanti değildir.';

  @override
  String get stakeSheetMaxButton => 'MAKS';

  @override
  String get stakePlaced => 'Tahmin gönderildi.';

  @override
  String get confirmStake => 'Tahmini onayla';

  @override
  String confirmStakeMessage(String amount) {
    return 'Bu tahmine $amount puan ayırmak istediğinize emin misiniz?';
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
    return '+$amount puan eklendi!';
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
  String get toldyaParticipants => 'Tahminciler';

  @override
  String get dataPreference => 'Veri tercihi';

  @override
  String get darkModeAppearance => 'Koyu mod görünümü';

  @override
  String get wifiOnly => 'Yalnızca Wi-Fi';

  @override
  String get tokenInsufficient => 'Puan yetersiz';

  @override
  String get closedNoSelection => 'Kapandığı için seçim yapılamaz';

  @override
  String get toldyaUnavailable => 'Bu gönderi kullanılamıyor';

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
  String get leaguePreSeasonTitle => 'Yeni Sezon İçin Nefesler Tutuldu! 🏆';

  @override
  String get leaguePreSeasonSubtitle =>
      'Rakiplerin belirleniyor... Lig atamaları yapıldığında burada 30 kişilik grubunla kıyasıya bir mücadele başlayacak.';

  @override
  String leagueCountdown(int days, int hours) {
    return '$days gün $hours saat';
  }

  @override
  String get tokenInsufficientForVote =>
      'Puan yetersiz olduğu için seçim yapılamaz';

  @override
  String get stakeErrorGeneric => 'Tahmin gönderilemedi.';

  @override
  String get stakeErrorUnauthenticated =>
      'Tahmin yapmak için giriş yapmanız gerekiyor.';

  @override
  String get stakeErrorDeadlineExceeded =>
      'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';

  @override
  String get stakeErrorResourceExhausted =>
      'Şu anda çok fazla istek var. Lütfen biraz sonra tekrar deneyin.';

  @override
  String get stakeErrorFailedPrecondition =>
      'Bu gönderi için şu anda tahmin yapılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get statuPending => 'Beklemede';

  @override
  String get statuUnderReview => 'İncelemede';

  @override
  String get statuRejectedByAi => 'Reddedildi';

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
  String get stakeTimeout =>
      'Tahmin isteği zaman aşımına uğradı. Lütfen tekrar deneyin.';

  @override
  String get gmsUpdateMessage =>
      'Google Play Services hatası. Lütfen cihazınızı yeniden başlatın veya Google Play Services\'i güncelleyin.';

  @override
  String featureComingSoon(String feature) {
    return '$feature yakında eklenecek.';
  }

  @override
  String get tokenEarnTitle => 'Puan Kazan';

  @override
  String get watchAdTitle => 'Reklam İzle';

  @override
  String tokenEarnFreeSubtitle(String amount) {
    return '$amount puan ücretsiz';
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
  String get tokenPacksTitle => 'Puan Paketleri';

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
  String get sortByXpFirst => 'En yüksek XP (deneyim) önce';

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
  String get notificationCommentedOnPost => 'tahminine yorum yaptı';

  @override
  String get notificationStartedFollowingYou => 'seni takip etmeye başladı';

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
  String get noParticipantScoreYet => 'Henüz tahmin skoru yok';

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
  String get appleSignInFailed => 'Apple ile giriş yapılamadı.';

  @override
  String get appleSignInNotConfigured =>
      'Apple girişi yapılandırılmamış. Firebase Console\'da Apple sağlayıcısını etkinleştirin.';

  @override
  String get appleSignInButton => 'Apple ile Bağlan';

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
  String get noStakesYet => 'Henüz tahmin yok.';

  @override
  String get noStakesYetHint =>
      'Yukarıdaki \"Evet\" veya \"Hayır\" butonuna dokunarak tahmin yapabilirsiniz.';

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
  String get editPrediction => 'Tahmini düzenle';

  @override
  String get predictionUpdated => 'Tahmin güncellendi';

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
  String get myStakesTab => 'Tahminlerim';

  @override
  String get myVotesTab => 'Oy verdiklerim';

  @override
  String get defaultUserHandle => '@kullanıcı';

  @override
  String get someone => 'Bir kullanıcı';

  @override
  String get youAreBlocked => 'Engellendin';

  @override
  String balanceToken(int count) {
    return 'Puan: $count';
  }

  @override
  String dailyBonusClaim(int amount) {
    return 'Günlük bonusu al (+$amount puan)';
  }

  @override
  String get tokenManagement => 'Puan Yönetimi';

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
  String get userHandlePlaceholder => '@kullanıcı';

  @override
  String closingAt(String time) {
    return 'Kapanış: $time';
  }

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
  String get tokenLabel => 'Puan';

  @override
  String get bottomNavHome => 'Ana';

  @override
  String get bottomNavSearch => 'Arama';

  @override
  String get bottomNavNotifications => 'Bildirim';

  @override
  String get bottomNavProfile => 'Profil';

  @override
  String get bottomNavLeaderboard => 'Liderlik';

  @override
  String get goToProfile => 'Profile git';

  @override
  String get muteNotificationsForPost => 'Bu tahmin için bildirimleri kapat';

  @override
  String get unmuteNotificationsForPost => 'Bu tahmin için bildirimleri aç';

  @override
  String get notificationsMuted => 'Bildirimler kapatıldı';

  @override
  String get notificationsUnmuted => 'Bildirimler açıldı';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Taciz / Nefret';

  @override
  String get reportReasonMisleading => 'Yanıltıcı bilgi';

  @override
  String get reportReasonOther => 'Diğer';

  @override
  String get reportReceived => 'Şikayetiniz alındı';

  @override
  String get unfollow => 'Takipten çık';

  @override
  String get stakeAmountLabel => 'Tahmin puanı';

  @override
  String amountPlayed(String amount) {
    return '$amount oynandı';
  }

  @override
  String get liveLabel => 'CANLI';

  @override
  String get timeLeftLabel => 'Kalan';

  @override
  String get predictionEnded => 'Bitti';

  @override
  String get approvalPendingStatus => 'Seçim yapılmak üzere bekleyen statüde';

  @override
  String approvalSelectedForPost(String choice) {
    return 'Gönderi için $choice seçildi';
  }

  @override
  String get toldyaYesLabel => 'Evet tahmini yap';

  @override
  String get toldyaNoLabel => 'Hayır tahmini yap';

  @override
  String get recentStakesTitle => 'Son Tahminler';

  @override
  String get conversationInformationTitle => 'Görüşme bilgisi';

  @override
  String reportUser(String name) {
    return 'Rapor et: $name';
  }

  @override
  String get deleteConversationTitle => 'Görüşmeyi sil';

  @override
  String get receiveMessageRequestsTitle => 'Mesaj isteklerini al';

  @override
  String get showReadReceiptsTitle => 'Okundu bilgisini göster';

  @override
  String get receiveMessageRequestsSubtitle =>
      'Takip etmediğiniz kişiler de size doğrudan mesaj isteği gönderebilir.';

  @override
  String get showReadReceiptsSubtitle =>
      'Biri size mesaj gönderdiğinde, görüşmedeki kişiler gördüğünüzü bilir. Bu ayarı kapatırsanız, siz de başkalarının okundu bilgisini göremezsiniz.';

  @override
  String get pollEnded => 'Anket bitti';

  @override
  String get pollEndedIn => 'Anket şu kadar sürede bitiyor';

  @override
  String get pollDay => 'Gün';

  @override
  String get pollDays => 'Gün';

  @override
  String get pollHour => 'saat';

  @override
  String get pollHours => 'saat';

  @override
  String get pollMin => 'dk';

  @override
  String get selectImage => 'Bir resim seçin';

  @override
  String get useCameraLabel => 'Kamerayı kullan';

  @override
  String get useGalleryLabel => 'Galeriyi kullan';

  @override
  String get emptyPredictionsDefaultTitle => 'Henüz bir tahmin yok';

  @override
  String get emptyPredictionsDefaultSubtitle =>
      'Yeni tahminler burada görünecek.\nAltta bulunan butona dokunarak tahmin oluşturabilirsiniz.';

  @override
  String get interactionAndSocialHeader => 'Etkileşim ve Sosyal';

  @override
  String get commentPermissionTitle => 'Tahminlerime Yorum Yapabilenler';

  @override
  String get commentPermissionEveryone => 'Herkes';

  @override
  String get commentPermissionFollowed => 'Takip Ettiklerim';

  @override
  String get commentPermissionNone => 'Hiç Kimse';

  @override
  String get mentionPermissionTitle => 'Benden Bahsedebilenler (@mention)';

  @override
  String get contentModerationHeader => 'İçerik Denetimi';

  @override
  String get hideSensitiveContentTitle => 'Hassas İçerikleri Gizle';

  @override
  String get dataAndSystemHeader => 'Veri ve Sistem';

  @override
  String get locationDataTitle => 'Konum Verileri';

  @override
  String get legalHeader => 'Yasal Bilgiler';

  @override
  String get privacyPolicyRowTitle => 'Gizlilik Politikası';

  @override
  String get userAgreementRowTitle => 'Kullanıcı Sözleşmesi';

  @override
  String get legalUrlMissingSubtitle => 'Yakında eklenecek.';

  @override
  String get deleteAccountTitle => 'Hesabımı Sil';

  @override
  String get deleteAccountWarning =>
      'Bu işlem tamamlandığında tüm puanlarınız, stash\'iniz ve geçmişiniz kalıcı olarak silinecektir.';

  @override
  String get deleteAccountCannotBeUndone => 'Bu işlem geri alınamaz.';

  @override
  String get deleteAccountBusy => 'Siliniyor…';

  @override
  String get deleteAccountDeleteButton => 'Sil';

  @override
  String get deleteAccountSuccess => 'Hesabınız silindi.';

  @override
  String get deleteAccountErrorGeneric =>
      'Hesabınızı silerken bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get mutedWordsComingSoonTitle => 'Sessize alınan kelimeler (yakında)';

  @override
  String get mutedWordsComingSoonSubtitle => 'Bu özellik henüz hazır değil.';

  @override
  String get blockedAccountsEmptyTitle => 'Henüz engellenen hesap yok';

  @override
  String get blockedAccountsEmptySubtitle =>
      'Engellediğiniz hesaplar burada görünecek.';

  @override
  String get unblockButton => 'Engeli kaldır';

  @override
  String get unblockSuccess => 'Kullanıcının engeli kaldırıldı.';

  @override
  String get legalUrlMissingTitle => 'Yasal metin URL\'si eksik';

  @override
  String get openLegalButton => 'Tarayıcıda aç';

  @override
  String get changePasswordTitle => 'Şifre Değiştir';

  @override
  String get languageOptionTurkish => 'Türkçe';

  @override
  String get languageOptionEnglish => 'İngilizce';

  @override
  String get languageOptionGerman => 'Almanca';

  @override
  String get logoutActionTitle => 'Çıkış Yap';
}
