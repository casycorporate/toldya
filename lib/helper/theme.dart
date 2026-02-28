import 'package:flutter/material.dart';

/// Tasarım: Minimalist 2024–2025, flat/hafif depth. 8px grid, dark öncelikli.
/// Doküman: docs/ui_redesign_prompts.md

/// 8px grid spacing
const double spacing4 = 4.0;
const double spacing8 = 8.0;
const double spacing12 = 12.0;
const double spacing16 = 16.0;
const double spacing24 = 24.0;
const double spacing32 = 32.0;

/// Bileşen radius (8–16px)
const double radiusSmall = 8.0;
const double radiusMedium = 12.0;
const double radiusCard = 16.0;

/// Minimal gölge (flat / çok hafif depth)
List<BoxShadow> shadow = <BoxShadow>[
  BoxShadow(
    blurRadius: 6,
    offset: Offset(0, 2),
    color: Colors.black26,
    spreadRadius: 0,
  ),
];
String get description => '';
TextStyle get onPrimaryTitleText =>
    TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
TextStyle get onPrimarySubTitleText => TextStyle(color: Colors.white);
BoxDecoration softDecoration = BoxDecoration(
  boxShadow: <BoxShadow>[
    BoxShadow(
      blurRadius: 8,
      offset: Offset(5, 5),
      color: Color(0xffe2e5ed),
      spreadRadius: 5,
    ),
    BoxShadow(
      blurRadius: 8,
      offset: Offset(-5, -5),
      color: Color(0xffffffff),
      spreadRadius: 5,
    ),
  ],
  color: Color(0xfff1f3f6),
);
TextStyle get titleStyle =>
    TextStyle(
        color: useDarkTheme ? AppColor.textPrimaryDark : AppColor.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold);
TextStyle get subtitleStyle => TextStyle(
    color: useDarkTheme ? AppColor.textSecondaryDark : AppColor.darkGrey,
    fontSize: 14,
    fontWeight: FontWeight.bold);
TextStyle get userNameStyle => TextStyle(
    color: useDarkTheme ? AppColor.textSecondaryDark : AppColor.darkGrey,
    fontSize: 12,
    fontWeight: FontWeight.bold);
TextStyle get textStyle14 => TextStyle(
    color: useDarkTheme ? AppColor.textSecondaryDark : AppColor.darkGrey,
    fontSize: 14,
    fontWeight: FontWeight.bold);

class ToldyaColor {
  static final Color bondiBlue = Color.fromRGBO(0, 132, 180, 1.0);
  static final Color yesGreen = Color.fromRGBO(18, 176, 55, 1);
  static final Color okRed = Color.fromRGBO(102, 37, 17, 1);
  static final Color noRed = Color.fromRGBO(217, 4, 4, 1);
  static final Color cerulean = Color.fromRGBO(0, 172, 237, 1.0);
  static final Color spindle = Color.fromRGBO(192, 222, 237, 1.0);
  static final Color white = Color.fromRGBO(255, 255, 255, 1.0);
  static final Color black = Color.fromRGBO(0, 0, 0, 1.0);
  static final Color woodsmoke = Color.fromRGBO(20, 23, 2, 1.0);
  static final Color woodsmoke_50 = Color.fromRGBO(20, 23, 2, 0.5);
  static final Color mystic = Color.fromRGBO(230, 236, 240, 1.0);
  static final Color dodgetBlue = Color(0xfff7892b);
  static final Color dodgetBlue_50 = Color.fromRGBO(29, 162, 240, 0.5);
  static final Color paleSky = Color.fromRGBO(101, 119, 133, 1.0);
  static final Color ceriseRed = Color.fromRGBO(224, 36, 94, 1.0);
  static final Color paleSky50 = Color.fromRGBO(101, 118, 133, 0.5);
  static final Color primaryColor = Colors.yellow.shade500;
}

/// Neon / vibrant accent palette (dark mode)
class AppNeon {
  static final Color orange = Color(0xFFFFA400);
  static final Color cyan = Color(0xFF00E5FF);
  static final Color green = Color(0xFF4CAF50);
  static final Color red = Color(0xFFE53935);
  static final Color pink = Color(0xFFFF4081);
  static final Color blue = Color(0xFF2196F3);
}

class AppColor {
  static final Color primary = Color(0xffFFA400);
  static final Color secondary = Color(0xff14171A);
  static final Color darkGrey = Color(0xff657786);
  static final Color lightGrey = Color(0xffAAB8C2);
  static final Color extraLightGrey = Color(0xffE1E8ED);
  static final Color extraExtraLightGrey = Color(0xfF5F8FA);
  static final Color white = Color(0xFFffffff);
  /// Dark theme surface (#1C1C1E benzeri minimalist brief)
  static final Color surfaceDark = Color(0xFF1C1C1E);
  static final Color cardDark = Color(0xFF252530);
  static final Color cardDarkBorder = Color(0xFF2C2C38);
  /// Text: theme’e göre (dark’ta beyaza yakın)
  static final Color textPrimary = Color(0xFF0D0D12);
  static final Color textPrimaryDark = Color(0xFFE8E8ED);
  static final Color textSecondaryDark = Color(0xFFA0A0B0);
}

/// Uygulama dark mode kullanıyor mu (tek tema tercihi)
bool get useDarkTheme => true;

/// Mockup’larla uyumlu tek tip değerler (kart, boşluk, radius)
class MockupDesign {
  MockupDesign._();
  // Renkler (dark)
  static const Color background = Color(0xFF1C1C1E);
  static const Color card = Color(0xFF252530);
  static const Color cardBorder = Color(0xFF2C2C38);
  static const Color accentOrange = Color(0xFFFFA400);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color textPrimary = Color(0xFFE8E8ED);
  static const Color textSecondary = Color(0xFFA0A0B0);
  // Ölçüler
  static const double cardRadius = 16.0;
  static const double cardPadding = 16.0;
  static const double screenPadding = 16.0;
  static const double avatarBorderWidth = 2.0;
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: Offset(0, 2),
          spreadRadius: 0,
        ),
      ];
}

class AppTheme {
  static ThemeData get apptheme => useDarkTheme ? _darkTheme : _lightTheme;

  static final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: ToldyaColor.white,
    primaryColor: AppColor.primary,
    cardColor: Colors.white,
    unselectedWidgetColor: Colors.grey,
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: AppColor.white),
    appBarTheme: AppBarTheme(
      backgroundColor: ToldyaColor.white,
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: ToldyaColor.dodgetBlue),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 26,
        fontStyle: FontStyle.normal,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: titleStyle.copyWith(color: ToldyaColor.dodgetBlue),
      unselectedLabelColor: AppColor.darkGrey,
      unselectedLabelStyle: titleStyle.copyWith(color: AppColor.darkGrey),
      labelColor: ToldyaColor.dodgetBlue,
      labelPadding: EdgeInsets.symmetric(vertical: 12),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ToldyaColor.dodgetBlue,
    ),
    colorScheme: ColorScheme.light(
      primary: ToldyaColor.dodgetBlue,
      secondary: AppColor.secondary,
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onError: Colors.white,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: AppColor.surfaceDark,
    primaryColor: AppNeon.orange,
    cardColor: AppColor.cardDark,
    unselectedWidgetColor: AppColor.textSecondaryDark,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColor.cardDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColor.surfaceDark,
      foregroundColor: AppColor.textPrimaryDark,
      iconTheme: IconThemeData(color: AppColor.textPrimaryDark, size: 24),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColor.textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: titleStyle.copyWith(color: AppNeon.orange, fontSize: 14),
      unselectedLabelColor: AppColor.textSecondaryDark,
      unselectedLabelStyle: titleStyle.copyWith(color: AppColor.textSecondaryDark, fontSize: 14),
      labelColor: AppNeon.orange,
      labelPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      indicatorColor: AppNeon.orange,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppNeon.orange,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    colorScheme: ColorScheme.dark(
      primary: AppNeon.orange,
      secondary: AppNeon.cyan,
      surface: AppColor.cardDark,
      error: AppNeon.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColor.textPrimaryDark,
      onError: Colors.white,
    ),
  );
}