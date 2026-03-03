import 'package:flutter/material.dart';

/// Tek logo: mavi yuvarlak arka plan, beyaz baykuş sembolü (SVG – her yerde kullan).
const String kToldyaLogo = 'assets/images/toldya.svg';

/// Dark tema logosu: koyu arka plan (#1C1C1E), beyaz baykuş.
const String kToldyaLogoDark = 'assets/images/toldya_dark.svg';

/// Varsayılan profil resmi (uygulama logosu).
String dummyProfilePic = kToldyaLogo;
String appFont = 'HelveticaNeuea';
/// Kayıt sırasında rastgele atanacak varsayılan avatarlar.
List<String> dummyProfilePicList = [
  'assets/images/avatar_1.png',
  'assets/images/avatar_2.png',
  'assets/images/avatar_3.png',
  'assets/images/avatar_4.png',
  'assets/images/avatar_5.png',
  kToldyaLogo,
  'assets/images/avatar_1.png',
  'assets/images/avatar_2.png',
];

/// Toldya logosu – yeni mavi baykuş (light/dark varyantlar).
class ToldyaBranding {
  ToldyaBranding._();
  static const String appIcon = kToldyaLogo;
  static const String logoPrimary = kToldyaLogo;
  static const String logoHorizontal = kToldyaLogo;
  static const String logoCompact = kToldyaLogo;
  static const String logoDark = kToldyaLogoDark;
}

class AppIcon{
  AppIcon._();

  static const _kFontFam = 'TwitterIcon';
  static const IconData fabToldya = IconData(0xf029, fontFamily: _kFontFam);
  static const IconData messageEmpty = IconData(0xf187, fontFamily: _kFontFam);
  static const IconData messageFill = IconData(0xf554, fontFamily: _kFontFam);
  static const IconData search = IconData(0xf058, fontFamily: _kFontFam);
  static const IconData searchFill = IconData(0xf558, fontFamily: _kFontFam);
  static const IconData notification = IconData(0xf055, fontFamily: _kFontFam);
  static const IconData notificationFill =
  IconData(0xf019, fontFamily: _kFontFam);
  static const IconData messageFab = IconData(0xf053, fontFamily: _kFontFam);
  static const IconData home = IconData(0xf053, fontFamily: _kFontFam);
  static const IconData homeFill = IconData(0xF553, fontFamily: _kFontFam);
  static const IconData heartEmpty = IconData(0xf148, fontFamily: _kFontFam);
  static const IconData heartFill = IconData(0xf015, fontFamily: _kFontFam);

  static const IconData settings = IconData(0xf059, fontFamily: _kFontFam);
  static const IconData adTheRate = IconData(0xf064, fontFamily: _kFontFam);
  static const IconData reply = IconData(0xf151, fontFamily: _kFontFam);
  static const IconData retweet = IconData(0xf152, fontFamily: _kFontFam);
  static const IconData image = IconData(0xf109, fontFamily: _kFontFam);
  static const IconData camera = IconData(0xf110, fontFamily: _kFontFam);
  static const IconData arrowDown = IconData(0xf196, fontFamily: _kFontFam);
  static const IconData blueTick = IconData(0xf099, fontFamily: _kFontFam);

  static const IconData link = IconData(0xf098, fontFamily: _kFontFam);
  static const IconData unFollow = IconData(0xf097, fontFamily: _kFontFam);
  static const IconData mute = IconData(0xf101, fontFamily: _kFontFam);
  static const IconData viewHidden = IconData(0xf156, fontFamily: _kFontFam);
  static const IconData block = IconData(0xe609, fontFamily: _kFontFam);
  static const IconData report = IconData(0xf038, fontFamily: _kFontFam);
  static const IconData pin = IconData(0xf088, fontFamily: _kFontFam);
  static const IconData delete = IconData(0xf154, fontFamily: _kFontFam);

  static const IconData profile = IconData(0xf056, fontFamily: _kFontFam);
  static const IconData lists = IconData(0xf094, fontFamily: _kFontFam);
  static const IconData bookmark = IconData(0xf155, fontFamily: _kFontFam);
  static const IconData moments = IconData(0xf160, fontFamily: _kFontFam);
  static const IconData twitterAds = IconData(0xf504, fontFamily: _kFontFam);
  static const IconData bulb = IconData(0xf567, fontFamily: _kFontFam);
  static const IconData newMessage = IconData(0xf035, fontFamily: _kFontFam);

  static const IconData sadFace = IconData(0xf430, fontFamily: _kFontFam);
  static const IconData bulbOn = IconData(0xf066, fontFamily: _kFontFam);
  static const IconData bulbOff = IconData(0xf567, fontFamily: _kFontFam);
  static const IconData follow = IconData(0xf175, fontFamily: _kFontFam);
  static const IconData thumbpinFill = IconData(0xf003, fontFamily: _kFontFam);
  static const IconData calender = IconData(0xf203, fontFamily: _kFontFam);
  static const IconData locationPin = IconData(0xf031, fontFamily: _kFontFam);
  static const IconData edit = IconData(0xf112, fontFamily: _kFontFam);
  static final int evetCommentFlag = 0;
  static final int hayirCommentFlag = 1;
  static final int pegCount = 50000;
  static final int defaultRank = 1;
  /// Uygulama komisyonu (0.0 - 1.0 arası, örn: 0.05 = %5)
  static const double commissionRate = 0.05;

  /// Tokenomics: Rütbe/XP sınırları (backend ile uyumlu)
  static const int xpCaylakMax = 500;
  static const int xpUstaMin = 2000;
  static const double rankMultiplierCaylak = 0.10;
  static const double rankMultiplierTahminci = 0.25;
  static const double rankMultiplierUsta = 0.50;
  static const int poolThreshold = 1000;
  static const int maxBetSmallPool = 100;
  static const int dailyBonusAmount = 500;

  /// Cloud Functions base URL (doğrudan HTTP ile çağrı – GMS broker hatası bypass)
  static const String cloudFunctionsBaseUrl = 'https://us-central1-casy-570c4.cloudfunctions.net';
}

class Tokenomics {
  Tokenomics._();
  static double rankMultiplierForXp(int xp) {
    if (xp < AppIcon.xpCaylakMax) return AppIcon.rankMultiplierCaylak;
    if (xp < AppIcon.xpUstaMin) return AppIcon.rankMultiplierTahminci;
    return AppIcon.rankMultiplierUsta;
  }
  static int maxBetByRank(int balance, int xp) =>
      (balance * rankMultiplierForXp(xp)).floor();
  static int maxBetByPool(int totalPool) =>
      totalPool < AppIcon.poolThreshold ? AppIcon.maxBetSmallPool : 0x7FFFFFFF;
}

class Role{
  Role._();

  static final int defaultRole=1;
  static final int adminRole=0;
}

/// Uygulama temasına uyumlu varsayılan kapak görselleri (profil banner).
/// Kullanıcı banner'ı yoksa veya URL yüklenemezse bunlardan biri rastgele gösterilir.
class DefaultBanners {
  DefaultBanners._();

  static const String key1 = 'default_1';
  static const String key2 = 'default_2';
  static const String key3 = 'default_3';

  static const List<String> keys = [key1, key2, key3];

  static const String asset1 = 'assets/images/banner_1.png';
  static const String asset2 = 'assets/images/banner_2.png';
  static const String asset3 = 'assets/images/banner_3.png';

  static const List<String> assets = [asset1, asset2, asset3];

  static bool isDefaultBannerKey(String? value) {
    if (value == null || value.isEmpty) return false;
    return value == key1 || value == key2 || value == key3;
  }

  static String? assetForKey(String? key) {
    if (key == key1) return asset1;
    if (key == key2) return asset2;
    if (key == key3) return asset3;
    return null;
  }

  /// Kullanıcıya göre sabit bir varsayılan banner (null/boş banner için).
  static String assetForUser(String? userId) {
    final index = (userId?.hashCode ?? DateTime.now().millisecondsSinceEpoch).abs() % 3;
    return assets[index];
  }
}

/// Varsayılan profil resimleri (5 adet). Boş profil resmi yerine kullanıcıya göre biri gösterilir.
class DefaultProfilePics {
  DefaultProfilePics._();

  static const String asset1 = 'assets/images/avatar_1.png';
  static const String asset2 = 'assets/images/avatar_2.png';
  static const String asset3 = 'assets/images/avatar_3.png';
  static const String asset4 = 'assets/images/avatar_4.png';
  static const String asset5 = 'assets/images/avatar_5.png';

  static const List<String> assets = [asset1, asset2, asset3, asset4, asset5];

  /// Kullanıcıya göre sabit bir varsayılan avatar (profil resmi boş/null için).
  static String assetForUser(String? userId) {
    final index = (userId?.hashCode ?? 0).abs() % 5;
    return assets[index];
  }
}

class Statu{
  Statu._();

  static final int statusLive=0;
  static final int statusPending=1;
  static final int statusOk=2;
  static final int statusDenied=3;
  static final int statusComplete=4;
  /// Kapanış zamanı geçti, bahisler kapandı, sonuç bekleniyor
  static final int statusLocked=5;
  /// Yapay zeka incelemesi bekliyor (henüz yayında değil)
  static final int statusPendingAiReview=6;
  /// Yapay zeka tarafından reddedildi (topluluk kuralları / tutarlılık)
  static final int statusRejectedByAi=7;
}
class FeedResult{
  FeedResult._();

  static final int feedResultUnFixed=0;
  static final int feedResultlike=1;
  static final int feedResultunLike=2;
}