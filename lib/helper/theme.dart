import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// DESIGN SYSTEM — Single source of truth for the entire Toldya app
// Modern dark prediction app: consistent colors, typography, spacing, radius
// =============================================================================

// -----------------------------------------------------------------------------
// SPACING (use consistently for padding, margins, gaps)
// -----------------------------------------------------------------------------
const double spacing4 = 4.0;
const double spacing8 = 8.0;
const double spacing12 = 12.0;
const double spacing16 = 16.0;
const double spacing20 = 20.0;
const double spacing24 = 24.0;
const double spacing32 = 32.0;

// -----------------------------------------------------------------------------
// RADIUS (cards, buttons, inputs, dialogs, sheets, badges)
// -----------------------------------------------------------------------------
const double radiusSmall = 10.0;
const double radiusMedium = 14.0;
const double radiusLarge = 16.0;
const double radiusXl = 20.0;

// Legacy aliases (prefer radius* above)
const double radiusCard = radiusLarge;
const double radiusButton = radiusMedium;

// -----------------------------------------------------------------------------
// COLORS — App-wide palette (dark product)
// -----------------------------------------------------------------------------
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121821);
  static const Color surfaceSecondary = Color(0xFF161D27);

  // Text
  static const Color textPrimary = Color(0xFFE6EAF0);
  static const Color textSecondary = Color(0xFF8A93A5);
  static const Color textMuted = Color(0xFF667085);

  // Borders / dividers
  static const Color border = Color(0xFF2A2F38);

  // YES accent (primary actions, Evet)
  static const Color yes = Color(0xFFFF8A3D);
  static const Color yesLight = Color(0xFFFFB36B);

  // NO accent (secondary actions, Hayır)
  static const Color no = Color(0xFF5561FF);
  static const Color noLight = Color(0xFF6A6FF5);

  // Status
  static const Color statusOpen = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // On-primary (button text etc.)
  static const Color onPrimary = Color(0xFFFFFFFF);
}

// Backward compatibility: ToldyaDesign and MockupDesign point to AppColors
class ToldyaDesign {
  ToldyaDesign._();
  static const Color background = AppColors.background;
  static const Color card = AppColors.card;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color yes = AppColors.yes;
  static const Color yesHighlight = AppColors.yesLight;
  static const Color no = AppColors.no;
  static const Color noHighlight = AppColors.noLight;
  static const Color progressYes = AppColors.yes;
  static const Color progressNo = AppColors.no;
  static const Color progressBackground = AppColors.border;
  static const Color statusBadge = AppColors.statusOpen;
  static const double cardRadius = radiusLarge;
  static const double cardPadding = spacing16;
  static const double cardMarginBottom = spacing12;
  static const double progressBarHeight = 6.0;
  static const double progressBarRadius = 20.0;
  static const double buttonRadius = radiusMedium;
  static const double buttonHeight = 48.0;
  static List<BoxShadow> get yesButtonShadow => [
        BoxShadow(
          color: yes.withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];
}

class MockupDesign {
  MockupDesign._();
  static const Color background = AppColors.background;
  static const Color card = AppColors.card;
  static const Color cardBorder = AppColors.border;
  static const Color accentOrange = AppColors.yes;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const double cardRadius = radiusLarge;
  static const double cardPadding = spacing16;
  static const double screenPadding = spacing16;
  static const double avatarBorderWidth = 2.0;
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];
}

// Legacy color classes (map to design system)
class AppColor {
  static final Color primary = AppColors.yes;
  static final Color secondary = AppColors.background;
  static final Color darkGrey = AppColors.textSecondary;
  static final Color textPrimaryDark = AppColors.textPrimary;
  static final Color textSecondaryDark = AppColors.textSecondary;
  static final Color surfaceDark = AppColors.surfaceSecondary;
  static final Color cardDark = AppColors.card;
  static final Color cardDarkBorder = AppColors.border;
  static final Color white = AppColors.onPrimary;
  static final Color extraLightGrey = AppColors.border;
  static final Color lightGrey = AppColors.textSecondary;
}

class AppNeon {
  static final Color orange = AppColors.yes;
  static final Color green = AppColors.statusOpen;
  static final Color red = AppColors.error;
  static final Color cyan = AppColors.no;
}

// -----------------------------------------------------------------------------
// TYPOGRAPHY — Inter, single hierarchy app-wide
// -----------------------------------------------------------------------------
// Display / page title: 28, w700
// Section title: 20, w600
// Card title / prediction: 18, w600
// Body: 15, w400
// Secondary / metadata: 13, w400
// Caption: 12, w400
// Button label: 15, w600

TextTheme _buildTextTheme() {
  final base = ThemeData.dark().textTheme;
  final inter = GoogleFonts.interTextTheme(base);
  return TextTheme(
    displayLarge: inter.displayLarge?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: inter.displayMedium?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: inter.displaySmall?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: inter.headlineLarge?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: inter.headlineMedium?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: inter.headlineSmall?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: inter.titleLarge?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: inter.titleMedium?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: inter.titleSmall?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: inter.bodyLarge?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: inter.bodyMedium?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: inter.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: inter.labelLarge?.copyWith(
      color: AppColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: inter.labelMedium?.copyWith(
      color: AppColors.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    labelSmall: inter.labelSmall?.copyWith(
      color: AppColors.textMuted,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  );
}

// -----------------------------------------------------------------------------
// LEGACY STYLES (theme-based for compatibility)
// -----------------------------------------------------------------------------
bool get useDarkTheme => true;

TextStyle get titleStyle => TextStyle(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
TextStyle get subtitleStyle => TextStyle(
      color: AppColors.textSecondary,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
TextStyle get userNameStyle => TextStyle(
      color: AppColors.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );
TextStyle get textStyle14 => TextStyle(
      color: AppColors.textSecondary,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
TextStyle get onPrimaryTitleText => TextStyle(
      color: AppColors.onPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
TextStyle get onPrimarySubTitleText => TextStyle(
      color: AppColors.onPrimary,
      fontSize: 15,
    );

List<BoxShadow> get shadow => [
      BoxShadow(
        blurRadius: 6,
        offset: const Offset(0, 2),
        color: Colors.black26,
        spreadRadius: 0,
      ),
    ];

BoxDecoration get softDecoration => BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(radiusLarge),
    );

// -----------------------------------------------------------------------------
// THEME DATA — Dark theme only, design system applied
// -----------------------------------------------------------------------------
class AppTheme {
  static ThemeData get apptheme => _darkTheme;

  static final ThemeData _darkTheme = _buildDarkTheme();

  static ThemeData _buildDarkTheme() {
    final textTheme = _buildTextTheme();
    final colorScheme = ColorScheme.dark(
      primary: AppColors.yes,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.yes.withValues(alpha: 0.2),
      onPrimaryContainer: AppColors.yesLight,
      secondary: AppColors.no,
      onSecondary: AppColors.onPrimary,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceSecondary,
      outline: AppColors.textSecondary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.yes,
      cardColor: AppColors.card,
      unselectedWidgetColor: AppColors.textSecondary,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      colorScheme: colorScheme,

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // Primary button: YES accent, 48h, radius 14
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yes,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // Secondary button: border NO accent
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.no,
          side: const BorderSide(color: AppColors.no),
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.yes,
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.yes, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSecondary,
        selectedColor: AppColors.yes.withValues(alpha: 0.2),
        labelStyle: textTheme.bodyMedium?.copyWith(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: spacing12, vertical: spacing8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        dragHandleColor: AppColors.textMuted,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.card,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      // Tab bar
      tabBarTheme: TabBarThemeData(
        labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.yes, fontSize: 15),
        unselectedLabelColor: AppColors.textSecondary,
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(color: AppColors.textSecondary, fontSize: 15),
        labelColor: AppColors.yes,
        labelPadding: const EdgeInsets.symmetric(vertical: spacing12, horizontal: spacing4),
        indicatorColor: AppColors.yes,
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.yes,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: AppColors.textPrimary,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
      ),
    );
  }
}

// Legacy ToldyaColor for any remaining references
class ToldyaColor {
  static final Color ceriseRed = AppColors.error;
  static final Color white = AppColors.onPrimary;
  static final Color dodgetBlue = AppColors.yes;
  static final Color cerulean = AppColors.no;
  static final Color mystic = AppColors.surfaceSecondary;
  static final Color paleSky50 = AppColors.textMuted.withValues(alpha: 0.5);
}
