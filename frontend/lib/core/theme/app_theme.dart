import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AppTheme defines the visual styling for the Gliss Mirror app.
/// It provides both light and dark theme variants following Henkel's brand guidelines.
class AppTheme {
  // Primary Foundation Colors
  static const Color henkelRed = Color(0xFFE1000F);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Substantial Base Colors
  static const Color sageGreen = Color(0xFFBFCFBE);
  static const Color softBlue = Color(0xFFBDCDDA);
  static const Color warmGrey = Color(0xFFDED7D6);

  // Welcoming Accents
  static const Color freshBlue = Color(0xFF318096);
  static const Color softMint = Color(0xFFDFEBC2);
  static const Color deepGreen = Color(0xFF175641);
  static const Color freshYellow = Color(0xFFF6E67D);
  static const Color deepViolet = Color(0xFF871964);
  static const Color softPeach = Color(0xFFF4C59E);

  // Progressive Colors
  static const Color electricYellow = Color(0xFFE8E200);
  static const Color brightAqua = Color(0xFF005FBE);
  static const Color brightMint = Color(0xFFA2ECBA);
  static const Color darkLilac = Color(0xFF69008C);
  static const Color brightOrange = Color(0xFFFBA700);
  static const Color darkBlue = Color(0xFF28325A);

  // Subtle Variations
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color sageDark = Color(0xFF53846A);
  static const Color sageLight = Color(0xFFE0E7DF);
  static const Color softBlueDark = Color(0xFF56729F);
  static const Color softBlueLight = Color(0xFFDEE5EB);
  static const Color warmGreyDark = Color(0xFF968282);
  static const Color warmGreyLight = Color(0xFFEFEBEA);

  // Damage Score Colors
  static const List<Color> damageScoreGradient = [
    sageGreen, // Healthy (1-3)
    freshYellow, // Moderate (4-6)
    brightOrange, // Severe (7-8)
    henkelRed, // Critical (9-10)
  ];

  // Semantic Colors
  static const Color error = henkelRed;
  static const Color success = sageGreen;
  static const Color warning = brightOrange;
  static const Color info = freshBlue;

  /// Text theme configuration for both light and dark modes
  // Spacing system based on 8px grid
  static const double spacing1 = 8;
  static const double spacing2 = 16;
  static const double spacing3 = 24;
  static const double spacing4 = 32;
  static const double spacing5 = 40;
  static const double spacing6 = 48;
  static const double spacing7 = 64;

  // Border radiuses
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;
  static const double radiusCircular = 999;

  // Shadows for elevation
  static final List<BoxShadow> elevation1 = [
    BoxShadow(
      color: darkBlue.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> elevation2 = [
    BoxShadow(
      color: darkBlue.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> elevation3 = [
    BoxShadow(
      color: darkBlue.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Typography
  static final _baseTextTheme = TextTheme(
    displayLarge: const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displayMedium: const TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),
    headlineLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.33,
    ),
    titleLarge: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    titleSmall: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),
    labelLarge: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
  );

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: henkelRed,
        secondary: deepViolet,
        tertiary: freshBlue,
        background: lightGrey,
        surface: pureWhite,
        error: error,
        onPrimary: pureWhite,
        onSecondary: pureWhite,
        onTertiary: pureWhite,
        onBackground: darkBlue,
        onSurface: darkBlue,
        onError: pureWhite,
        outline: warmGrey,
        surfaceVariant: warmGreyLight,
        onSurfaceVariant: warmGreyDark,
      ),
      textTheme: _baseTextTheme.apply(
        bodyColor: darkBlue,
        displayColor: darkBlue,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: henkelRed,
          foregroundColor: pureWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: henkelRed,
          side: const BorderSide(color: henkelRed, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warmGrey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warmGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warmGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: deepViolet, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: pureWhite,
        foregroundColor: darkBlue,
        elevation: 0,
        centerTitle: true,
      ),
      scaffoldBackgroundColor: pureWhite,
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: henkelRed,
        secondary: deepViolet,
        tertiary: freshBlue,
        background: darkBlue,
        surface: darkBlue.withOpacity(0.8),
        error: error,
        onPrimary: pureWhite,
        onSecondary: pureWhite,
        onTertiary: pureWhite,
        onBackground: pureWhite,
        onSurface: pureWhite,
        onError: pureWhite,
      ),
      textTheme: _baseTextTheme.apply(
        bodyColor: pureWhite,
        displayColor: pureWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: henkelRed,
          foregroundColor: pureWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pureWhite,
          side: const BorderSide(color: henkelRed, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBlue.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: warmGrey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: warmGrey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: deepViolet, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: darkBlue,
        foregroundColor: pureWhite,
        elevation: 0,
        centerTitle: true,
      ),
      scaffoldBackgroundColor: darkBlue,
      cardTheme: CardThemeData(
        color: darkBlue.withOpacity(0.8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
