import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Toldya'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get signUp;

  /// No description provided for @tagline.
  ///
  /// In tr, this message translates to:
  /// **'Tahminlerini paylaş, demiş mi dememiş mi gör.'**
  String get tagline;

  /// No description provided for @signInToContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için giriş yapın'**
  String get signInToContinue;

  /// No description provided for @followers.
  ///
  /// In tr, this message translates to:
  /// **'Takipçiler'**
  String get followers;

  /// No description provided for @follower.
  ///
  /// In tr, this message translates to:
  /// **'Takipçi'**
  String get follower;

  /// No description provided for @following.
  ///
  /// In tr, this message translates to:
  /// **'Takipler'**
  String get following;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @settingsAndPrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar ve gizlilik'**
  String get settingsAndPrivacy;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış'**
  String get logout;

  /// No description provided for @account.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get account;

  /// No description provided for @privacyAndPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve güvenlik'**
  String get privacyAndPolicy;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @followSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Takip edildi'**
  String get followSuccess;

  /// No description provided for @unfollowSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Takipten çıkıldı'**
  String get unfollowSuccess;

  /// No description provided for @errorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'İşlem yapılamadı. Lütfen tekrar deneyin.'**
  String get errorGeneric;

  /// No description provided for @pleaseEnterName.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen isim giriniz'**
  String get pleaseEnterName;

  /// No description provided for @nameTooLong.
  ///
  /// In tr, this message translates to:
  /// **'İsim uzunluğu 27 karakteri geçemez'**
  String get nameTooLong;

  /// No description provided for @pleaseFillForm.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen formu dikkatlice doldurunuz'**
  String get pleaseFillForm;

  /// No description provided for @passwordMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Parola ve doğrulama parolası eşleşmedi'**
  String get passwordMismatch;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In tr, this message translates to:
  /// **'Çıkmak için tekrar geri tuşuna basın'**
  String get pressBackAgainToExit;

  /// No description provided for @signUpNow.
  ///
  /// In tr, this message translates to:
  /// **'Hemen Kaydol'**
  String get signUpNow;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten bir hesabın var mı?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get signIn;

  /// No description provided for @name.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get name;

  /// No description provided for @enterEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-mail giriniz'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre giriniz'**
  String get enterPassword;

  /// No description provided for @enterPasswordAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar şifre giriniz'**
  String get enterPasswordAgain;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen e-posta adresini girin'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen şifrenizi giriniz'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 8 karakter uzunluğunda olmalı'**
  String get passwordMinLength;

  /// No description provided for @validEmailRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir e-posta adresi girin'**
  String get validEmailRequired;

  /// No description provided for @emailEmpty.
  ///
  /// In tr, this message translates to:
  /// **'E-posta alanı boş olamaz'**
  String get emailEmpty;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi unuttum?'**
  String get forgotPassword;

  /// No description provided for @shared.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşıldı.'**
  String get shared;

  /// No description provided for @postUnderReview.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiniz incelemeye alındı. Onaylandığında akışta görünecektir.'**
  String get postUnderReview;

  /// No description provided for @commentAdded.
  ///
  /// In tr, this message translates to:
  /// **'Yorumunuz eklendi.'**
  String get commentAdded;

  /// No description provided for @errorTryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu. Lütfen tekrar deneyin.'**
  String get errorTryAgain;

  /// No description provided for @post.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi'**
  String get post;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirm;

  /// No description provided for @continueAction.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueAction;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @disputeRecorded.
  ///
  /// In tr, this message translates to:
  /// **'İtirazınız kaydedildi'**
  String get disputeRecorded;

  /// No description provided for @predictionDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tahmin silindi.'**
  String get predictionDeleted;

  /// No description provided for @errorDeleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Silinirken bir hata oluştu. Lütfen tekrar deneyin.'**
  String get errorDeleteFailed;

  /// No description provided for @userBlocked.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı engellendi.'**
  String get userBlocked;

  /// No description provided for @userUnblocked.
  ///
  /// In tr, this message translates to:
  /// **'Engel kaldırıldı.'**
  String get userUnblocked;

  /// No description provided for @pleaseSelectBetAmount.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bahis miktarı seçin!'**
  String get pleaseSelectBetAmount;

  /// No description provided for @maxBetTokens.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum bahis: {maxVal} token'**
  String maxBetTokens(String maxVal);

  /// No description provided for @betOnOneSideOnly.
  ///
  /// In tr, this message translates to:
  /// **'Bu tahminde zaten diğer tarafa bahis yaptınız. Bir tahminde yalnızca tek tarafa (Evet veya Hayır) bahis yapabilirsiniz.'**
  String get betOnOneSideOnly;

  /// No description provided for @betPlaced.
  ///
  /// In tr, this message translates to:
  /// **'Bahis alındı.'**
  String get betPlaced;

  /// No description provided for @confirmBet.
  ///
  /// In tr, this message translates to:
  /// **'Bahsi onayla'**
  String get confirmBet;

  /// No description provided for @confirmBetMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu tahmine {amount} token ile bahis yapmak istediğinize emin misiniz?'**
  String confirmBetMessage(String amount);

  /// No description provided for @messageSent.
  ///
  /// In tr, this message translates to:
  /// **'Gönderildi'**
  String get messageSent;

  /// No description provided for @messageSendFailed.
  ///
  /// In tr, this message translates to:
  /// **'Gönderilemedi. Lütfen tekrar deneyin.'**
  String get messageSendFailed;

  /// No description provided for @usernameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı boş bırakılamaz'**
  String get usernameRequired;

  /// No description provided for @usernameRules.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı {min}–{max} karakter olmalı; sadece harf, rakam ve alt çizgi kullanılabilir.'**
  String usernameRules(int min, int max);

  /// No description provided for @usernameTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı alınmış'**
  String get usernameTaken;

  /// No description provided for @errorCheckFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol sırasında bir hata oluştu'**
  String get errorCheckFailed;

  /// No description provided for @errorSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilirken bir hata oluştu'**
  String get errorSaveFailed;

  /// No description provided for @nameTooLongProfile.
  ///
  /// In tr, this message translates to:
  /// **'İsim uzunluğu 27 karakteri aşamaz'**
  String get nameTooLongProfile;

  /// No description provided for @adsComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Reklam özelliği yakında eklenecek.'**
  String get adsComingSoon;

  /// No description provided for @tokensAdded.
  ///
  /// In tr, this message translates to:
  /// **'+{amount} token eklendi!'**
  String tokensAdded(String amount);

  /// No description provided for @purchaseComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma yakında eklenecek.'**
  String get purchaseComingSoon;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ara...'**
  String get searchHint;

  /// No description provided for @trendPredictions.
  ///
  /// In tr, this message translates to:
  /// **'Trend Tahminler'**
  String get trendPredictions;

  /// No description provided for @noPredictionsInCategory.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride tahmin yok'**
  String get noPredictionsInCategory;

  /// No description provided for @recentSearches.
  ///
  /// In tr, this message translates to:
  /// **'Son Aramalar'**
  String get recentSearches;

  /// No description provided for @liveSuggestions.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Öneriler'**
  String get liveSuggestions;

  /// No description provided for @noResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç yok'**
  String get noResults;

  /// No description provided for @predictions.
  ///
  /// In tr, this message translates to:
  /// **'Tahminler'**
  String get predictions;

  /// No description provided for @people.
  ///
  /// In tr, this message translates to:
  /// **'Kişiler'**
  String get people;

  /// No description provided for @user.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get user;

  /// No description provided for @usernameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı'**
  String get usernameLabel;

  /// No description provided for @prediction.
  ///
  /// In tr, this message translates to:
  /// **'Tahmin'**
  String get prediction;

  /// No description provided for @noPredictionResult.
  ///
  /// In tr, this message translates to:
  /// **'Tahmin sonucu yok'**
  String get noPredictionResult;

  /// No description provided for @noPersonResult.
  ///
  /// In tr, this message translates to:
  /// **'Kişi sonucu yok'**
  String get noPersonResult;

  /// No description provided for @noPredictionOutcome.
  ///
  /// In tr, this message translates to:
  /// **'Tahmin sonucu yok'**
  String get noPredictionOutcome;

  /// No description provided for @followingLabel.
  ///
  /// In tr, this message translates to:
  /// **'Takip ediliyor'**
  String get followingLabel;

  /// No description provided for @follow.
  ///
  /// In tr, this message translates to:
  /// **'Takip Et'**
  String get follow;

  /// No description provided for @categoryFlow.
  ///
  /// In tr, this message translates to:
  /// **'Akış'**
  String get categoryFlow;

  /// No description provided for @categoryFavorite.
  ///
  /// In tr, this message translates to:
  /// **'Favori'**
  String get categoryFavorite;

  /// No description provided for @categoryFollow.
  ///
  /// In tr, this message translates to:
  /// **'Takip'**
  String get categoryFollow;

  /// No description provided for @categorySports.
  ///
  /// In tr, this message translates to:
  /// **'Spor'**
  String get categorySports;

  /// No description provided for @categoryEconomy.
  ///
  /// In tr, this message translates to:
  /// **'Ekonomi'**
  String get categoryEconomy;

  /// No description provided for @categoryEntertainment.
  ///
  /// In tr, this message translates to:
  /// **'Eğlence'**
  String get categoryEntertainment;

  /// No description provided for @categoryPolitics.
  ///
  /// In tr, this message translates to:
  /// **'Siyaset'**
  String get categoryPolitics;

  /// No description provided for @aboutToldya.
  ///
  /// In tr, this message translates to:
  /// **'Toldya Hakkında'**
  String get aboutToldya;

  /// No description provided for @help.
  ///
  /// In tr, this message translates to:
  /// **'Yardım'**
  String get help;

  /// No description provided for @legal.
  ///
  /// In tr, this message translates to:
  /// **'Yasal'**
  String get legal;

  /// No description provided for @developer.
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici'**
  String get developer;

  /// No description provided for @newMessage.
  ///
  /// In tr, this message translates to:
  /// **'Yeni mesaj'**
  String get newMessage;

  /// No description provided for @messages.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get messages;

  /// No description provided for @predictors.
  ///
  /// In tr, this message translates to:
  /// **'Tahminciler'**
  String get predictors;

  /// No description provided for @bettors.
  ///
  /// In tr, this message translates to:
  /// **'Bahisçiler'**
  String get bettors;

  /// No description provided for @dataPreference.
  ///
  /// In tr, this message translates to:
  /// **'Veri tercihi'**
  String get dataPreference;

  /// No description provided for @darkModeAppearance.
  ///
  /// In tr, this message translates to:
  /// **'Koyu mod görünümü'**
  String get darkModeAppearance;

  /// No description provided for @wifiOnly.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca Wi-Fi'**
  String get wifiOnly;

  /// No description provided for @tokenInsufficient.
  ///
  /// In tr, this message translates to:
  /// **'Token yetersiz'**
  String get tokenInsufficient;

  /// No description provided for @closedNoSelection.
  ///
  /// In tr, this message translates to:
  /// **'Kapandığı için seçim yapılamaz'**
  String get closedNoSelection;

  /// No description provided for @thisTweetUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderi kullanılamıyor'**
  String get thisTweetUnavailable;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get editProfile;

  /// No description provided for @challengeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Meydan oku: '**
  String get challengeLabel;

  /// No description provided for @selectUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı seç'**
  String get selectUser;

  /// No description provided for @challengePickTitle.
  ///
  /// In tr, this message translates to:
  /// **'Meydan oku: Kullanıcı seç'**
  String get challengePickTitle;

  /// No description provided for @followingListEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Kimseyi takip etmiyorsunuz. Önce takip listesine ekleyin.'**
  String get followingListEmpty;

  /// No description provided for @followingListLoadingOrEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Takip listeniz yükleniyor veya listede kullanıcı bulunamadı.'**
  String get followingListLoadingOrEmpty;

  /// No description provided for @agree.
  ///
  /// In tr, this message translates to:
  /// **'Katılıyorum'**
  String get agree;

  /// No description provided for @disagree.
  ///
  /// In tr, this message translates to:
  /// **'Katılmıyorum'**
  String get disagree;

  /// No description provided for @voteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Oylama gönderilemedi.'**
  String get voteFailed;

  /// No description provided for @comments.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get comments;

  /// No description provided for @noCommentsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz yorum yok. İlk yorumu sen yap.'**
  String get noCommentsYet;

  /// No description provided for @predictionDetail.
  ///
  /// In tr, this message translates to:
  /// **'Tahmin Detayı'**
  String get predictionDetail;

  /// No description provided for @leaderboardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Liderlik Tablosu'**
  String get leaderboardTitle;

  /// No description provided for @weeklyLeague.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Lig'**
  String get weeklyLeague;

  /// No description provided for @leagueNotCreatedYet.
  ///
  /// In tr, this message translates to:
  /// **'Bu haftanın lig grubu henüz oluşturulmadı.'**
  String get leagueNotCreatedYet;

  /// No description provided for @leagueWillAppearWhenAssigned.
  ///
  /// In tr, this message translates to:
  /// **'Lig ataması yapıldığında burada görüneceksin.'**
  String get leagueWillAppearWhenAssigned;

  /// No description provided for @tokenInsufficientForVote.
  ///
  /// In tr, this message translates to:
  /// **'Token yetersiz olduğu için seçim yapılamaz'**
  String get tokenInsufficientForVote;

  /// No description provided for @betErrorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bahis gönderilemedi.'**
  String get betErrorGeneric;

  /// No description provided for @gmsError.
  ///
  /// In tr, this message translates to:
  /// **'Google Play Services hatası: {message}'**
  String gmsError(String message);

  /// No description provided for @unknownError.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen hata'**
  String get unknownError;

  /// No description provided for @errorWithMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hata: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @changesSaved.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler kaydedildi'**
  String get changesSaved;

  /// No description provided for @resetPasswordSent.
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.'**
  String get resetPasswordSent;

  /// No description provided for @selectProfilePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı seç'**
  String get selectProfilePhoto;

  /// No description provided for @selectCoverPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Kapak fotoğrafı seç'**
  String get selectCoverPhoto;

  /// No description provided for @appAvatars.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama avatarları'**
  String get appAvatars;

  /// No description provided for @appCovers.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama kapakları'**
  String get appCovers;

  /// No description provided for @exampleUsername.
  ///
  /// In tr, this message translates to:
  /// **'Örn: kullanici_123'**
  String get exampleUsername;

  /// No description provided for @bio.
  ///
  /// In tr, this message translates to:
  /// **'Biyografi'**
  String get bio;

  /// No description provided for @location.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get location;

  /// No description provided for @birthDate.
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihi'**
  String get birthDate;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @sortUserList.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı listesini sırala'**
  String get sortUserList;

  /// No description provided for @updateNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Güncelle'**
  String get updateNow;

  /// No description provided for @alert.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı'**
  String get alert;

  /// No description provided for @forIos.
  ///
  /// In tr, this message translates to:
  /// **'iOS için'**
  String get forIos;

  /// No description provided for @forAndroid.
  ///
  /// In tr, this message translates to:
  /// **'Android için'**
  String get forAndroid;

  /// No description provided for @iSayYes.
  ///
  /// In tr, this message translates to:
  /// **'dedim'**
  String get iSayYes;

  /// No description provided for @iSayNo.
  ///
  /// In tr, this message translates to:
  /// **'demedim'**
  String get iSayNo;

  /// No description provided for @votersList.
  ///
  /// In tr, this message translates to:
  /// **'Seçim yapanlar'**
  String get votersList;

  /// No description provided for @noVotesYet.
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderiye henüz seçim yapılmadı'**
  String get noVotesYet;

  /// No description provided for @voteListEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir kullanıcı bu gönderi için seçim yaptığında kullanıcı listesi burada gösterilecektir.'**
  String get voteListEmptySubtitle;

  /// No description provided for @commentFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yorum eklenemedi. Lütfen tekrar deneyin.'**
  String get commentFailed;

  /// No description provided for @loginRequired.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapmanız gerekiyor.'**
  String get loginRequired;

  /// No description provided for @betTimeout.
  ///
  /// In tr, this message translates to:
  /// **'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.'**
  String get betTimeout;

  /// No description provided for @gmsUpdateMessage.
  ///
  /// In tr, this message translates to:
  /// **'Google Play Services hatası. Lütfen cihazınızı yeniden başlatın veya Google Play Services\'i güncelleyin.'**
  String get gmsUpdateMessage;

  /// No description provided for @featureComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'{feature} yakında eklenecek.'**
  String featureComingSoon(String feature);

  /// No description provided for @tokenEarnTitle.
  ///
  /// In tr, this message translates to:
  /// **'Token Kazan'**
  String get tokenEarnTitle;

  /// No description provided for @watchAdTitle.
  ///
  /// In tr, this message translates to:
  /// **'Reklam İzle'**
  String get watchAdTitle;

  /// No description provided for @tokenEarnFreeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{amount} Token ücretsiz'**
  String tokenEarnFreeSubtitle(String amount);

  /// No description provided for @watch.
  ///
  /// In tr, this message translates to:
  /// **'İzle'**
  String get watch;

  /// No description provided for @dailyBonusTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Bonus'**
  String get dailyBonusTitle;

  /// No description provided for @claim.
  ///
  /// In tr, this message translates to:
  /// **'Al'**
  String get claim;

  /// No description provided for @tryAgainTomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın tekrar dene'**
  String get tryAgainTomorrow;

  /// No description provided for @tokenPacksTitle.
  ///
  /// In tr, this message translates to:
  /// **'Token Paketleri'**
  String get tokenPacksTitle;

  /// No description provided for @mostPopular.
  ///
  /// In tr, this message translates to:
  /// **'En popüler'**
  String get mostPopular;

  /// No description provided for @bestValue.
  ///
  /// In tr, this message translates to:
  /// **'En iyi değer'**
  String get bestValue;

  /// No description provided for @dataUsageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Veri kullanımı'**
  String get dataUsageTitle;

  /// No description provided for @dataSaverHeader.
  ///
  /// In tr, this message translates to:
  /// **'Veri tasarrufu'**
  String get dataSaverHeader;

  /// No description provided for @dataSaverTitle.
  ///
  /// In tr, this message translates to:
  /// **'Veri tasarrufu'**
  String get dataSaverTitle;

  /// No description provided for @dataSaverSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Etkinleştirildiğinde video otomatik oynatılmaz ve daha düşük kaliteli görseller yüklenir. Bu, bu cihazdaki tüm hesaplar için veri kullanımını azaltır.'**
  String get dataSaverSubtitle;

  /// No description provided for @imagesHeader.
  ///
  /// In tr, this message translates to:
  /// **'Görseller'**
  String get imagesHeader;

  /// No description provided for @highQualityImagesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek kaliteli görseller'**
  String get highQualityImagesTitle;

  /// No description provided for @highQualityImagesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{network}\\n\\nYüksek kaliteli görsellerin ne zaman yükleneceğini seçin.'**
  String highQualityImagesSubtitle(String network);

  /// No description provided for @videoHeader.
  ///
  /// In tr, this message translates to:
  /// **'Video'**
  String get videoHeader;

  /// No description provided for @highQualityVideoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek kaliteli video'**
  String get highQualityVideoTitle;

  /// No description provided for @highQualityVideoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{network}\\n\\nEn yüksek kalitenin ne zaman oynatılacağını seçin.'**
  String highQualityVideoSubtitle(String network);

  /// No description provided for @videoAutoplayTitle.
  ///
  /// In tr, this message translates to:
  /// **'Video otomatik oynatma'**
  String get videoAutoplayTitle;

  /// No description provided for @videoAutoplaySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{network}\\n\\nVideonun ne zaman otomatik oynatılacağını seçin.'**
  String videoAutoplaySubtitle(String network);

  /// No description provided for @dataSyncHeader.
  ///
  /// In tr, this message translates to:
  /// **'Veri senkronizasyonu'**
  String get dataSyncHeader;

  /// No description provided for @syncDataTitle.
  ///
  /// In tr, this message translates to:
  /// **'Verileri senkronize et'**
  String get syncDataTitle;

  /// No description provided for @syncIntervalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Senkronizasyon aralığı'**
  String get syncIntervalTitle;

  /// No description provided for @daily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get daily;

  /// No description provided for @syncDataDescription.
  ///
  /// In tr, this message translates to:
  /// **'Toldya\'nın deneyiminizi geliştirmek için arka planda verileri senkronize etmesine izin verin.'**
  String get syncDataDescription;

  /// No description provided for @mobileDataWifi.
  ///
  /// In tr, this message translates to:
  /// **'Mobil veri ve Wi‑Fi'**
  String get mobileDataWifi;

  /// No description provided for @never.
  ///
  /// In tr, this message translates to:
  /// **'Asla'**
  String get never;

  /// No description provided for @dim.
  ///
  /// In tr, this message translates to:
  /// **'Kısık'**
  String get dim;

  /// No description provided for @lightOut.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık'**
  String get lightOut;

  /// No description provided for @darkModeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Mod'**
  String get darkModeTitle;

  /// No description provided for @on.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get on;

  /// No description provided for @off.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get off;

  /// No description provided for @automaticAtSunset.
  ///
  /// In tr, this message translates to:
  /// **'Gün batımında otomatik'**
  String get automaticAtSunset;

  /// No description provided for @verifiedUserFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce doğrulanmış kullanıcılar'**
  String get verifiedUserFirst;

  /// No description provided for @newestUserFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce en yeni kullanıcılar'**
  String get newestUserFirst;

  /// No description provided for @oldestUserFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce en eski kullanıcılar'**
  String get oldestUserFirst;

  /// No description provided for @maxFollowerFirst.
  ///
  /// In tr, this message translates to:
  /// **'En çok takipçili kullanıcılar'**
  String get maxFollowerFirst;

  /// No description provided for @alphabeticallySort.
  ///
  /// In tr, this message translates to:
  /// **'Alfabetik'**
  String get alphabeticallySort;

  /// No description provided for @displayAndSoundTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görüntü ve ses'**
  String get displayAndSoundTitle;

  /// No description provided for @mediaHeader.
  ///
  /// In tr, this message translates to:
  /// **'Medya'**
  String get mediaHeader;

  /// No description provided for @mediaPreviewsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Medya önizlemeleri'**
  String get mediaPreviewsTitle;

  /// No description provided for @displayHeader.
  ///
  /// In tr, this message translates to:
  /// **'Görüntü'**
  String get displayHeader;

  /// No description provided for @emojiTitle.
  ///
  /// In tr, this message translates to:
  /// **'Emoji'**
  String get emojiTitle;

  /// No description provided for @emojiSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Cihazınızın varsayılan seti yerine uygulama setini kullanın'**
  String get emojiSubtitle;

  /// No description provided for @soundHeader.
  ///
  /// In tr, this message translates to:
  /// **'Ses'**
  String get soundHeader;

  /// No description provided for @soundEffectsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ses efektleri'**
  String get soundEffectsTitle;

  /// No description provided for @webBrowserHeader.
  ///
  /// In tr, this message translates to:
  /// **'Web tarayıcısı'**
  String get webBrowserHeader;

  /// No description provided for @useInAppBrowserTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama içi tarayıcıyı kullan'**
  String get useInAppBrowserTitle;

  /// No description provided for @useInAppBrowserSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Harici bağlantıları uygulama içi tarayıcıyla aç'**
  String get useInAppBrowserSubtitle;

  /// No description provided for @accessibilityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Erişilebilirlik'**
  String get accessibilityTitle;

  /// No description provided for @screenReaderHeader.
  ///
  /// In tr, this message translates to:
  /// **'Ekran okuyucu'**
  String get screenReaderHeader;

  /// No description provided for @pronounceHashtagTitle.
  ///
  /// In tr, this message translates to:
  /// **'# işaretini \"hashtag\" olarak telaffuz et'**
  String get pronounceHashtagTitle;

  /// No description provided for @visionHeader.
  ///
  /// In tr, this message translates to:
  /// **'Görme'**
  String get visionHeader;

  /// No description provided for @composeImageDescriptionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görsel açıklaması yaz'**
  String get composeImageDescriptionsTitle;

  /// No description provided for @composeImageDescriptionsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Görme engelli kullanıcılar için görselleri açıklama özelliği ekler.'**
  String get composeImageDescriptionsSubtitle;

  /// No description provided for @motionHeader.
  ///
  /// In tr, this message translates to:
  /// **'Hareket'**
  String get motionHeader;

  /// No description provided for @reduceMotionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hareketi azalt'**
  String get reduceMotionTitle;

  /// No description provided for @reduceMotionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Canlı etkileşim sayıları dahil uygulama içi animasyonları azaltın.'**
  String get reduceMotionSubtitle;

  /// No description provided for @accountTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get accountTitle;

  /// No description provided for @loginHeader.
  ///
  /// In tr, this message translates to:
  /// **'Giriş'**
  String get loginHeader;

  /// No description provided for @emailAddressTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi'**
  String get emailAddressTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notificationsTitle;

  /// No description provided for @filtersHeader.
  ///
  /// In tr, this message translates to:
  /// **'Filtreler'**
  String get filtersHeader;

  /// No description provided for @qualityFilterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kalite filtresi'**
  String get qualityFilterTitle;

  /// No description provided for @qualityFilterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Düşük kaliteli bildirimleri filtreleyin. Takip ettiğiniz kişilerden veya son zamanlarda etkileşimde bulunduğunuz hesaplardan gelen bildirimleri filtrelemez.'**
  String get qualityFilterSubtitle;

  /// No description provided for @advancedFilterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş filtre'**
  String get advancedFilterTitle;

  /// No description provided for @mutedWordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sessize alınan kelimeler'**
  String get mutedWordTitle;

  /// No description provided for @preferencesHeader.
  ///
  /// In tr, this message translates to:
  /// **'Tercihler'**
  String get preferencesHeader;

  /// No description provided for @unreadBadgeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Okunmamış bildirim rozeti'**
  String get unreadBadgeTitle;

  /// No description provided for @unreadBadgeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama içinde sizi bekleyen bildirim sayısını rozet olarak gösterin.'**
  String get unreadBadgeSubtitle;

  /// No description provided for @pushNotificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Anlık bildirimler'**
  String get pushNotificationsTitle;

  /// No description provided for @smsNotificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'SMS bildirimleri'**
  String get smsNotificationsTitle;

  /// No description provided for @emailNotificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta bildirimleri'**
  String get emailNotificationsTitle;

  /// No description provided for @emailNotificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamanın size ne zaman ve ne sıklıkla e-posta göndereceğini kontrol edin.'**
  String get emailNotificationsSubtitle;

  /// No description provided for @contentPreferencesTitle.
  ///
  /// In tr, this message translates to:
  /// **'İçerik tercihleri'**
  String get contentPreferencesTitle;

  /// No description provided for @exploreHeader.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get exploreHeader;

  /// No description provided for @trendsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Trendler'**
  String get trendsTitle;

  /// No description provided for @searchSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arama ayarları'**
  String get searchSettingsTitle;

  /// No description provided for @languagesHeader.
  ///
  /// In tr, this message translates to:
  /// **'Diller'**
  String get languagesHeader;

  /// No description provided for @recommendationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Öneriler'**
  String get recommendationsTitle;

  /// No description provided for @recommendationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen gönderilerin, kişilerin ve trendlerin hangi dilleri içereceğini seçin'**
  String get recommendationsSubtitle;

  /// No description provided for @safetyHeader.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get safetyHeader;

  /// No description provided for @blockedAccountsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Engellenen hesaplar'**
  String get blockedAccountsTitle;

  /// No description provided for @mutedAccountsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sessize alınan hesaplar'**
  String get mutedAccountsTitle;

  /// No description provided for @helpHeader.
  ///
  /// In tr, this message translates to:
  /// **'Yardım'**
  String get helpHeader;

  /// No description provided for @helpCenterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yardım merkezi'**
  String get helpCenterTitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım şartları'**
  String get termsOfServiceTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik politikası'**
  String get privacyPolicyTitle;

  /// No description provided for @cookieUseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çerez kullanımı'**
  String get cookieUseTitle;

  /// No description provided for @legalNoticesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yasal bildirimler'**
  String get legalNoticesTitle;

  /// No description provided for @searchFilterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arama filtresi'**
  String get searchFilterTitle;

  /// No description provided for @trendsLocationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Trend konumu'**
  String get trendsLocationTitle;

  /// No description provided for @emailVerificationSent.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama bağlantısı e-posta adresinize gönderildi.'**
  String get emailVerificationSent;

  /// No description provided for @privacyAndSafetyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve güvenlik'**
  String get privacyAndSafetyTitle;

  /// No description provided for @privacySharesHeader.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşımlar'**
  String get privacySharesHeader;

  /// No description provided for @protectPostsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşımlarınızı koru'**
  String get protectPostsTitle;

  /// No description provided for @protectPostsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşımlarınızı yalnızca mevcut takipçileriniz ve ileride onay vereceğiniz kişiler görebilir.'**
  String get protectPostsSubtitle;

  /// No description provided for @photoTaggingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf etiketleme'**
  String get photoTaggingTitle;

  /// No description provided for @photoTaggingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Herkes sizi etiketleyebilir'**
  String get photoTaggingSubtitle;

  /// No description provided for @liveVideoHeader.
  ///
  /// In tr, this message translates to:
  /// **'Canlı yayın'**
  String get liveVideoHeader;

  /// No description provided for @connectToLiveVideoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Canlı yayına bağlan'**
  String get connectToLiveVideoTitle;

  /// No description provided for @connectToLiveVideoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Açık olduğunda canlı yayın yapabilir ve yorum yapabilirsiniz; kapalı olduğunda diğerleri canlı yayın veya yorum yapamaz.'**
  String get connectToLiveVideoSubtitle;

  /// No description provided for @discoverabilityHeader.
  ///
  /// In tr, this message translates to:
  /// **'Keşfedilebilirlik ve kişiler'**
  String get discoverabilityHeader;

  /// No description provided for @discoverabilityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Keşfedilebilirlik ve kişiler'**
  String get discoverabilityTitle;

  /// No description provided for @discoverabilitySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu verilerin sizi diğer kişilerle nasıl eşleştirmek için kullanıldığı hakkında daha fazla bilgi edinin.'**
  String get discoverabilitySubtitle;

  /// No description provided for @securityHeader.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get securityHeader;

  /// No description provided for @showSensitiveMediaTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hassas içerik barındırabilecek medyayı göster'**
  String get showSensitiveMediaTitle;

  /// No description provided for @markSensitiveMediaTitle.
  ///
  /// In tr, this message translates to:
  /// **'Paylaştığınız medyayı hassas içerik barındırabilir olarak işaretle'**
  String get markSensitiveMediaTitle;

  /// No description provided for @mutedWordsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sessize alınan kelimeler'**
  String get mutedWordsTitle;

  /// No description provided for @locationHeader.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get locationHeader;

  /// No description provided for @preciseLocationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tam konum'**
  String get preciseLocationTitle;

  /// No description provided for @preciseLocationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı\\n\\n\\nAçık olduğunda Toldya, cihazınızın tam konumunu (GPS bilgisi gibi) toplar, saklar ve kullanır. Bu sayede Toldya deneyiminizi iyileştirir; örneğin daha yerel içerik, reklam ve öneriler sunar.'**
  String get preciseLocationSubtitle;

  /// No description provided for @personalizationHeader.
  ///
  /// In tr, this message translates to:
  /// **'Kişiselleştirme ve veri'**
  String get personalizationHeader;

  /// No description provided for @personalizationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişiselleştirme ve veri'**
  String get personalizationTitle;

  /// No description provided for @allowAllSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tümüne izin ver'**
  String get allowAllSubtitle;

  /// No description provided for @viewYourDataTitle.
  ///
  /// In tr, this message translates to:
  /// **'Toldya verilerinizi görüntüle'**
  String get viewYourDataTitle;

  /// No description provided for @viewYourDataSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil bilgilerinizi ve hesabınızla ilişkili verileri inceleyin ve düzenleyin.'**
  String get viewYourDataSubtitle;

  /// No description provided for @proxyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Proxy'**
  String get proxyTitle;

  /// No description provided for @enableHttpProxyTitle.
  ///
  /// In tr, this message translates to:
  /// **'HTTP Proxy\'yi etkinleştir'**
  String get enableHttpProxyTitle;

  /// No description provided for @enableHttpProxySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ağ istekleri için HTTP proxy yapılandırın (not: tarayıcı için geçerli değildir).'**
  String get enableHttpProxySubtitle;

  /// No description provided for @proxyHostTitle.
  ///
  /// In tr, this message translates to:
  /// **'Proxy sunucusu'**
  String get proxyHostTitle;

  /// No description provided for @proxyHostSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Proxy ana bilgisayar adını yapılandırın.'**
  String get proxyHostSubtitle;

  /// No description provided for @proxyPortTitle.
  ///
  /// In tr, this message translates to:
  /// **'Proxy portu'**
  String get proxyPortTitle;

  /// No description provided for @proxyPortSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Proxy port numarasını yapılandırın.'**
  String get proxyPortSubtitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bildirim yok'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bildirim geldiğinde burada görünecek.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @votedOnYourPost.
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi paylaşımınıza oy verdi'**
  String votedOnYourPost(int count);

  /// No description provided for @emailVerificationTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta doğrulama'**
  String get emailVerificationTitle;

  /// No description provided for @emailVerifiedTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresiniz doğrulandı'**
  String get emailVerifiedTitle;

  /// No description provided for @emailVerifiedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Mavi tiki aldınız. Tebrikler!'**
  String get emailVerifiedSubtitle;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinizi doğrulayın'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulamak için {email} adresine doğrulama bağlantısı gönderin.'**
  String verifyEmailSubtitle(String email);

  /// No description provided for @sendLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı gönder'**
  String get sendLink;

  /// No description provided for @noPredictorScoreYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tahminci skoru yok'**
  String get noPredictorScoreYet;

  /// No description provided for @noBettorScoreYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bahisçi skoru yok'**
  String get noBettorScoreYet;

  /// No description provided for @followersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takipçiler'**
  String get followersTitle;

  /// No description provided for @noFollowersYet.
  ///
  /// In tr, this message translates to:
  /// **'{username} hiç takipçisi yok'**
  String noFollowersYet(String username);

  /// No description provided for @followersWillAppearHere.
  ///
  /// In tr, this message translates to:
  /// **'Biri takip ettiğinde burada listelenir.'**
  String get followersWillAppearHere;

  /// No description provided for @newMessageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni mesaj'**
  String get newMessageTitle;

  /// No description provided for @searchPeopleOrGroupsHint.
  ///
  /// In tr, this message translates to:
  /// **'Kişi veya grup ara'**
  String get searchPeopleOrGroupsHint;

  /// No description provided for @googleSignInFailed.
  ///
  /// In tr, this message translates to:
  /// **'Google ile giriş yapılamadı.'**
  String get googleSignInFailed;

  /// No description provided for @googleSignInNotConfigured.
  ///
  /// In tr, this message translates to:
  /// **'Google girişi yapılandırılmamış. Firebase Console\'da uygulama SHA parmak izini ekleyin.'**
  String get googleSignInNotConfigured;

  /// No description provided for @googleSignInButton.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Bağlan'**
  String get googleSignInButton;

  /// No description provided for @adminFilterLive.
  ///
  /// In tr, this message translates to:
  /// **'Devam eden'**
  String get adminFilterLive;

  /// No description provided for @adminFilterPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen'**
  String get adminFilterPending;

  /// No description provided for @adminFilterApproved.
  ///
  /// In tr, this message translates to:
  /// **'Onaylanan'**
  String get adminFilterApproved;

  /// No description provided for @adminFilterRejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddedilen'**
  String get adminFilterRejected;

  /// No description provided for @adminFilterCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan'**
  String get adminFilterCompleted;

  /// No description provided for @adminFilterPendingAiReview.
  ///
  /// In tr, this message translates to:
  /// **'AI incelemesinde'**
  String get adminFilterPendingAiReview;

  /// No description provided for @adminFilterRejectedByAi.
  ///
  /// In tr, this message translates to:
  /// **'AI reddi'**
  String get adminFilterRejectedByAi;

  /// No description provided for @xpProgressLabel.
  ///
  /// In tr, this message translates to:
  /// **'{xp} / {max}'**
  String xpProgressLabel(int xp, int max);

  /// No description provided for @xpProgressMaxLabel.
  ///
  /// In tr, this message translates to:
  /// **'{xp} (Usta)'**
  String xpProgressMaxLabel(int xp);

  /// No description provided for @rankRookie.
  ///
  /// In tr, this message translates to:
  /// **'Çaylak'**
  String get rankRookie;

  /// No description provided for @rankPredictor.
  ///
  /// In tr, this message translates to:
  /// **'Tahminci'**
  String get rankPredictor;

  /// No description provided for @rankMaster.
  ///
  /// In tr, this message translates to:
  /// **'Usta'**
  String get rankMaster;

  /// No description provided for @xpHintToBecomePredictor.
  ///
  /// In tr, this message translates to:
  /// **'{threshold} XP\'de Tahminci olursun'**
  String xpHintToBecomePredictor(int threshold);

  /// No description provided for @xpHintToBecomeMaster.
  ///
  /// In tr, this message translates to:
  /// **'{threshold} XP\'de Usta olursun'**
  String xpHintToBecomeMaster(int threshold);

  /// No description provided for @xpHintMaxRank.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum rütbedesin'**
  String get xpHintMaxRank;

  /// No description provided for @rankProgressTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rütbe ilerlemesi'**
  String get rankProgressTitle;

  /// No description provided for @levelLabel.
  ///
  /// In tr, this message translates to:
  /// **'Seviye {level}'**
  String levelLabel(String level);

  /// No description provided for @noBetsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bahis yok.'**
  String get noBetsYet;

  /// No description provided for @noBetsYetHint.
  ///
  /// In tr, this message translates to:
  /// **'Yukarıdaki \"Evet ile bahis yap\" veya \"Hayır ile bahis yap\" butonuna tıklayarak bahis yapabilirsiniz.'**
  String get noBetsYetHint;

  /// No description provided for @dailyBonusClaimed.
  ///
  /// In tr, this message translates to:
  /// **'Günlük bonus alındı.'**
  String get dailyBonusClaimed;

  /// No description provided for @copyLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı kopyala'**
  String get copyLink;

  /// No description provided for @copiedToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Panoya kopyalandı'**
  String get copiedToClipboard;

  /// No description provided for @postTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi'**
  String get postTitle;

  /// No description provided for @sharedPostDescription.
  ///
  /// In tr, this message translates to:
  /// **'{displayName} bir gönderi paylaştı'**
  String sharedPostDescription(String displayName);

  /// No description provided for @sharedPredictionDescription.
  ///
  /// In tr, this message translates to:
  /// **'{displayName} Toldya uygulamasında bir toldya paylaştı.'**
  String sharedPredictionDescription(String displayName);

  /// No description provided for @editBioHint.
  ///
  /// In tr, this message translates to:
  /// **'Biyografiyi güncellemek için profili düzenle'**
  String get editBioHint;

  /// No description provided for @noBio.
  ///
  /// In tr, this message translates to:
  /// **'Biyografi yok'**
  String get noBio;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @editPrediction.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini düzenle'**
  String get editPrediction;

  /// No description provided for @predictionUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Tahmin güncellendi'**
  String get predictionUpdated;

  /// No description provided for @muteUser.
  ///
  /// In tr, this message translates to:
  /// **'{name} sessize al'**
  String muteUser(String name);

  /// No description provided for @muteConversation.
  ///
  /// In tr, this message translates to:
  /// **'Bu görüşmeyi sessize al'**
  String get muteConversation;

  /// No description provided for @viewHiddenReplies.
  ///
  /// In tr, this message translates to:
  /// **'Gizli yanıtları görüntüle'**
  String get viewHiddenReplies;

  /// No description provided for @blockUser.
  ///
  /// In tr, this message translates to:
  /// **'{name} engelle'**
  String blockUser(String name);

  /// No description provided for @unblockUser.
  ///
  /// In tr, this message translates to:
  /// **'{name} engeli kaldır'**
  String unblockUser(String name);

  /// No description provided for @report.
  ///
  /// In tr, this message translates to:
  /// **'Rapor et'**
  String get report;

  /// No description provided for @withdrawReport.
  ///
  /// In tr, this message translates to:
  /// **'Şikayeti geri al'**
  String get withdrawReport;

  /// No description provided for @sendForApproval.
  ///
  /// In tr, this message translates to:
  /// **'Onaya gönder'**
  String get sendForApproval;

  /// No description provided for @approve.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get reject;

  /// No description provided for @dispute.
  ///
  /// In tr, this message translates to:
  /// **'İtiraz et'**
  String get dispute;

  /// No description provided for @disputed.
  ///
  /// In tr, this message translates to:
  /// **'İtiraz ettiniz'**
  String get disputed;

  /// No description provided for @writeMessageHint.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj yazın...'**
  String get writeMessageHint;

  /// No description provided for @commentHint.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yazın...'**
  String get commentHint;

  /// No description provided for @searchHintShort.
  ///
  /// In tr, this message translates to:
  /// **'Ara..'**
  String get searchHintShort;

  /// No description provided for @directMessagesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Direkt mesajlar'**
  String get directMessagesTitle;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @shareImageLink.
  ///
  /// In tr, this message translates to:
  /// **'Görsel bağlantısını paylaş'**
  String get shareImageLink;

  /// No description provided for @openInBrowser.
  ///
  /// In tr, this message translates to:
  /// **'Tarayıcıda aç'**
  String get openInBrowser;

  /// No description provided for @newUpdateAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Yeni güncelleme mevcut'**
  String get newUpdateAvailable;

  /// No description provided for @unsupportedVersionMessage.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamanın mevcut sürümü artık desteklenmiyor. Vermiş olabileceğimiz her türlü rahatsızlıktan dolayı özür dileriz.'**
  String get unsupportedVersionMessage;

  /// No description provided for @seeLeaderboard.
  ///
  /// In tr, this message translates to:
  /// **'Liderlik tablosunda gör'**
  String get seeLeaderboard;

  /// No description provided for @profileShareTitle.
  ///
  /// In tr, this message translates to:
  /// **'{name} Toldya\'da'**
  String profileShareTitle(String name);

  /// No description provided for @profileShareDescription.
  ///
  /// In tr, this message translates to:
  /// **'{name} profilini incele'**
  String profileShareDescription(String name);

  /// No description provided for @trendsLocationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'New York'**
  String get trendsLocationSubtitle;

  /// No description provided for @trendsLocationHint.
  ///
  /// In tr, this message translates to:
  /// **'Trendler sekmenizde hangi konumun görüneceğini seçerek belirli bir konumda nelerin trend olduğunu görebilirsiniz.'**
  String get trendsLocationHint;

  /// No description provided for @myBetsTab.
  ///
  /// In tr, this message translates to:
  /// **'Bahislerim'**
  String get myBetsTab;

  /// No description provided for @myVotesTab.
  ///
  /// In tr, this message translates to:
  /// **'Oy verdiklerim'**
  String get myVotesTab;

  /// No description provided for @defaultUserHandle.
  ///
  /// In tr, this message translates to:
  /// **'@kullanıcı'**
  String get defaultUserHandle;

  /// No description provided for @youAreBlocked.
  ///
  /// In tr, this message translates to:
  /// **'Engellendin'**
  String get youAreBlocked;

  /// No description provided for @balanceToken.
  ///
  /// In tr, this message translates to:
  /// **'Bakiye: {count} Token'**
  String balanceToken(int count);

  /// No description provided for @dailyBonusClaim.
  ///
  /// In tr, this message translates to:
  /// **'Günlük bonusu al (+{amount} token)'**
  String dailyBonusClaim(int amount);

  /// No description provided for @tokenManagement.
  ///
  /// In tr, this message translates to:
  /// **'Token Yönetimi'**
  String get tokenManagement;

  /// No description provided for @emptyActivePredictions.
  ///
  /// In tr, this message translates to:
  /// **'Aktif tahminin yok'**
  String get emptyActivePredictions;

  /// No description provided for @emptyPendingPredictions.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen tahminin yok'**
  String get emptyPendingPredictions;

  /// No description provided for @emptyCompletedPredictions.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan tahminin yok'**
  String get emptyCompletedPredictions;

  /// No description provided for @emptyRejectedPredictions.
  ///
  /// In tr, this message translates to:
  /// **'Reddedilen tahminin yok'**
  String get emptyRejectedPredictions;

  /// No description provided for @emptyLockedPredictions.
  ///
  /// In tr, this message translates to:
  /// **'Kilitli tahminin yok'**
  String get emptyLockedPredictions;

  /// No description provided for @emptyMyNoVotes.
  ///
  /// In tr, this message translates to:
  /// **'Hiç oy vermedin'**
  String get emptyMyNoVotes;

  /// No description provided for @emptyMyNoPosts.
  ///
  /// In tr, this message translates to:
  /// **'Hiç gönderi yok'**
  String get emptyMyNoPosts;

  /// No description provided for @emptyMyNoMedia.
  ///
  /// In tr, this message translates to:
  /// **'Hiç gönderi veya medya yok'**
  String get emptyMyNoMedia;

  /// No description provided for @emptyOtherNoVotes.
  ///
  /// In tr, this message translates to:
  /// **'{name} hiç oy vermedi'**
  String emptyOtherNoVotes(String name);

  /// No description provided for @emptyOtherNoPosts.
  ///
  /// In tr, this message translates to:
  /// **'{name} hiç gönderi yok'**
  String emptyOtherNoPosts(String name);

  /// No description provided for @emptyOtherNoMedia.
  ///
  /// In tr, this message translates to:
  /// **'{name} hiç gönderi veya medya yok'**
  String emptyOtherNoMedia(String name);

  /// No description provided for @filterActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get filterActive;

  /// No description provided for @filterPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen'**
  String get filterPending;

  /// No description provided for @filterCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan'**
  String get filterCompleted;

  /// No description provided for @filterRejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddedilen'**
  String get filterRejected;

  /// No description provided for @filterLocked.
  ///
  /// In tr, this message translates to:
  /// **'Kilitli'**
  String get filterLocked;

  /// No description provided for @addNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi ekle'**
  String get addNow;

  /// No description provided for @willShowHere.
  ///
  /// In tr, this message translates to:
  /// **'Burada gösterilecekler'**
  String get willShowHere;

  /// No description provided for @topicGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get topicGeneral;

  /// No description provided for @userHandlePlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'@kullanıcı'**
  String get userHandlePlaceholder;

  /// No description provided for @closingAt.
  ///
  /// In tr, this message translates to:
  /// **'Kapanış: {time}'**
  String closingAt(String time);

  /// No description provided for @yesPercent.
  ///
  /// In tr, this message translates to:
  /// **'Evet {percent}'**
  String yesPercent(int percent);

  /// No description provided for @noPercent.
  ///
  /// In tr, this message translates to:
  /// **'Hayır {percent}'**
  String noPercent(int percent);

  /// No description provided for @followingCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Takipler'**
  String get followingCountLabel;

  /// No description provided for @tokenLabel.
  ///
  /// In tr, this message translates to:
  /// **'Token'**
  String get tokenLabel;

  /// No description provided for @bottomNavHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana'**
  String get bottomNavHome;

  /// No description provided for @bottomNavSearch.
  ///
  /// In tr, this message translates to:
  /// **'Arama'**
  String get bottomNavSearch;

  /// No description provided for @bottomNavNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim'**
  String get bottomNavNotifications;

  /// No description provided for @bottomNavProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get bottomNavProfile;

  /// No description provided for @goToProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profile git'**
  String get goToProfile;

  /// No description provided for @muteNotificationsForPost.
  ///
  /// In tr, this message translates to:
  /// **'Bu tahmin için bildirimleri kapat'**
  String get muteNotificationsForPost;

  /// No description provided for @unmuteNotificationsForPost.
  ///
  /// In tr, this message translates to:
  /// **'Bu tahmin için bildirimleri aç'**
  String get unmuteNotificationsForPost;

  /// No description provided for @notificationsMuted.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler kapatıldı'**
  String get notificationsMuted;

  /// No description provided for @notificationsUnmuted.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler açıldı'**
  String get notificationsUnmuted;

  /// No description provided for @reportReasonSpam.
  ///
  /// In tr, this message translates to:
  /// **'Spam'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In tr, this message translates to:
  /// **'Taciz / Nefret'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonMisleading.
  ///
  /// In tr, this message translates to:
  /// **'Yanıltıcı bilgi'**
  String get reportReasonMisleading;

  /// No description provided for @reportReasonOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get reportReasonOther;

  /// No description provided for @reportReceived.
  ///
  /// In tr, this message translates to:
  /// **'Şikayetiniz alındı'**
  String get reportReceived;

  /// No description provided for @unfollow.
  ///
  /// In tr, this message translates to:
  /// **'Takipten çık'**
  String get unfollow;

  /// No description provided for @betAmountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bahis miktarı'**
  String get betAmountLabel;

  /// No description provided for @approvalPendingStatus.
  ///
  /// In tr, this message translates to:
  /// **'Seçim yapılmak üzere bekleyen statüde'**
  String get approvalPendingStatus;

  /// No description provided for @approvalSelectedForPost.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi için {choice} seçildi'**
  String approvalSelectedForPost(String choice);

  /// No description provided for @betYesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Evet ile bahis yap'**
  String get betYesLabel;

  /// No description provided for @betNoLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hayır ile bahis yap'**
  String get betNoLabel;

  /// No description provided for @recentBetsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son Bahisler'**
  String get recentBetsTitle;

  /// No description provided for @conversationInformationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görüşme bilgisi'**
  String get conversationInformationTitle;

  /// No description provided for @reportUser.
  ///
  /// In tr, this message translates to:
  /// **'Rapor et: {name}'**
  String reportUser(String name);

  /// No description provided for @deleteConversationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görüşmeyi sil'**
  String get deleteConversationTitle;

  /// No description provided for @receiveMessageRequestsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj isteklerini al'**
  String get receiveMessageRequestsTitle;

  /// No description provided for @showReadReceiptsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Okundu bilgisini göster'**
  String get showReadReceiptsTitle;

  /// No description provided for @receiveMessageRequestsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Takip etmediğiniz kişiler de size doğrudan mesaj isteği gönderebilir.'**
  String get receiveMessageRequestsSubtitle;

  /// No description provided for @showReadReceiptsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Biri size mesaj gönderdiğinde, görüşmedeki kişiler gördüğünüzü bilir. Bu ayarı kapatırsanız, siz de başkalarının okundu bilgisini göremezsiniz.'**
  String get showReadReceiptsSubtitle;

  /// No description provided for @pollEnded.
  ///
  /// In tr, this message translates to:
  /// **'Anket bitti'**
  String get pollEnded;

  /// No description provided for @pollEndedIn.
  ///
  /// In tr, this message translates to:
  /// **'Anket şu kadar sürede bitiyor'**
  String get pollEndedIn;

  /// No description provided for @pollDay.
  ///
  /// In tr, this message translates to:
  /// **'Gün'**
  String get pollDay;

  /// No description provided for @pollDays.
  ///
  /// In tr, this message translates to:
  /// **'Gün'**
  String get pollDays;

  /// No description provided for @pollHour.
  ///
  /// In tr, this message translates to:
  /// **'saat'**
  String get pollHour;

  /// No description provided for @pollHours.
  ///
  /// In tr, this message translates to:
  /// **'saat'**
  String get pollHours;

  /// No description provided for @pollMin.
  ///
  /// In tr, this message translates to:
  /// **'dk'**
  String get pollMin;

  /// No description provided for @selectImage.
  ///
  /// In tr, this message translates to:
  /// **'Bir resim seçin'**
  String get selectImage;

  /// No description provided for @useCameraLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kamerayı kullan'**
  String get useCameraLabel;

  /// No description provided for @useGalleryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Galeriyi kullan'**
  String get useGalleryLabel;

  /// No description provided for @emptyPredictionsDefaultTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir tahmin yok'**
  String get emptyPredictionsDefaultTitle;

  /// No description provided for @emptyPredictionsDefaultSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni tahminler burada görünecek.\nAltta bulunan butona dokunarak tahmin oluşturabilirsiniz.'**
  String get emptyPredictionsDefaultSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
