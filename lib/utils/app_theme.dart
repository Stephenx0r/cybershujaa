import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF8B5CF6);
  
  // Secondary Colors
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentBlue = Color(0xFF3B82F6);
  
  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textLightLight = Color(0xFF9CA3AF);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color iconLight = Color(0xFF6B7280);
  
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textLightDark = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0xFF475569);
  static const Color iconDark = Color(0xFF94A3B8);
  
  // High Contrast Theme Colors (Accessibility)
  static const Color highContrastBackground = Color(0xFF000000);
  static const Color highContrastSurface = Color(0xFF1A1A1A);
  static const Color highContrastText = Color(0xFFFFFFFF);
  static const Color highContrastAccent = Color(0xFFFFD700);
  static const Color highContrastError = Color(0xFFFF6B6B);
  static const Color highContrastSuccess = Color(0xFF00FF00);
  
  // Semantic Colors for Accessibility
  static const Color semanticSuccess = Color(0xFF059669);
  static const Color semanticWarning = Color(0xFFD97706);
  static const Color semanticError = Color(0xFFDC2626);
  static const Color semanticInfo = Color(0xFF2563EB);
  
  // Legacy colors for backward compatibility
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient streakGradient = LinearGradient(
    colors: [accentOrange, accentRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [accentGreen, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // High Contrast Gradients
  static const LinearGradient highContrastGradient = LinearGradient(
    colors: [highContrastAccent, Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 15,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];
  
  // High Contrast Shadows
  static const List<BoxShadow> highContrastShadow = [
    BoxShadow(
      color: Color(0x40FFFFFF),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  
  // Spacing
  static const double spaceXSmall = 4.0;
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;
  
  // Typography with Accessibility
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.4,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    height: 1.4,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.6,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.6,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.6,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  // Accessibility-focused typography
  static const TextStyle accessibleBodyLarge = TextStyle(
    fontSize: 18.0, // Larger for better readability
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.8, // Increased line height
  );
  
  static const TextStyle accessibleBodyMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.8,
  );
  
  // Legacy methods for backward compatibility
  static TextStyle getHeadlineLarge(bool isDark) {
    return headlineLarge.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getHeadlineMedium(bool isDark) {
    return headlineMedium.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getHeadlineSmall(bool isDark) {
    return headlineSmall.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getTitleLarge(bool isDark) {
    return titleLarge.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getTitleMedium(bool isDark) {
    return titleMedium.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getTitleSmall(bool isDark) {
    return titleSmall.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getBodyLarge(bool isDark) {
    return bodyLarge.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getBodyMedium(bool isDark) {
    return bodyMedium.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getBodySmall(bool isDark) {
    return bodySmall.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getLabelLarge(bool isDark) {
    return labelLarge.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getLabelMedium(bool isDark) {
    return labelMedium.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  static TextStyle getLabelSmall(bool isDark) {
    return labelSmall.copyWith(
      color: isDark ? textPrimaryDark : textPrimaryLight,
    );
  }
  
  // Button styles for backward compatibility
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryPurple,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(
      horizontal: spaceLarge,
      vertical: spaceMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
  );
  
  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: primaryPurple,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: spaceLarge,
      vertical: spaceMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      side: const BorderSide(color: primaryPurple, width: 1),
    ),
  );
  
  // Difficulty color method
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return accentGreen;
      case 'medium':
        return accentOrange;
      case 'hard':
        return accentRed;
      default:
        return accentBlue;
    }
  }
  
  // Build Light Theme
  static ThemeData buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: accentOrange,
        surface: surfaceLight,
        background: backgroundLight,
        error: semanticError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onBackground: textPrimaryLight,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLarge,
            vertical: spaceMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMedium,
          vertical: spaceMedium,
        ),
      ),
    );
  }
  
  // Build Dark Theme
  static ThemeData buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: accentOrange,
        surface: surfaceDark,
        background: backgroundDark,
        error: semanticError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onBackground: textPrimaryDark,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: headlineLarge.copyWith(color: textPrimaryDark),
        headlineMedium: headlineMedium.copyWith(color: textPrimaryDark),
        headlineSmall: headlineSmall.copyWith(color: textPrimaryDark),
        titleLarge: titleLarge.copyWith(color: textPrimaryDark),
        titleMedium: titleMedium.copyWith(color: textPrimaryDark),
        titleSmall: titleSmall.copyWith(color: textPrimaryDark),
        bodyLarge: bodyLarge.copyWith(color: textPrimaryDark),
        bodyMedium: bodyMedium.copyWith(color: textPrimaryDark),
        bodySmall: bodySmall.copyWith(color: textPrimaryDark),
        labelLarge: labelLarge.copyWith(color: textPrimaryDark),
        labelMedium: labelMedium.copyWith(color: textPrimaryDark),
        labelSmall: labelSmall.copyWith(color: textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLarge,
            vertical: spaceMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMedium,
          vertical: spaceMedium,
        ),
      ),
    );
  }
  
  // Build High Contrast Theme (Accessibility)
  static ThemeData buildHighContrastTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: highContrastAccent,
        secondary: highContrastAccent,
        surface: highContrastSurface,
        background: highContrastBackground,
        error: highContrastError,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: highContrastText,
        onBackground: highContrastText,
        onError: Colors.black,
      ),
      textTheme: TextTheme(
        headlineLarge: accessibleBodyLarge.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: accessibleBodyMedium.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: accessibleBodyMedium.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: accessibleBodyMedium.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: accessibleBodyMedium.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: accessibleBodyMedium.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: accessibleBodyLarge.copyWith(color: highContrastText),
        bodyMedium: accessibleBodyMedium.copyWith(color: highContrastText),
        bodySmall: accessibleBodyMedium.copyWith(color: highContrastText),
        labelLarge: accessibleBodyMedium.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: accessibleBodyMedium.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: accessibleBodyMedium.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: highContrastAccent.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: const BorderSide(color: highContrastAccent, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLarge,
            vertical: spaceMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            side: const BorderSide(color: highContrastAccent, width: 2),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: highContrastAccent, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: highContrastAccent, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMedium,
          vertical: spaceMedium,
        ),
      ),
    );
  }
  
  // Get theme based on accessibility preferences
  static ThemeData getThemeForAccessibility({
    required bool isDarkMode,
    required bool isHighContrast,
    required double textScaleFactor,
  }) {
    if (isHighContrast) {
      return buildHighContrastTheme();
    }
    
    final baseTheme = isDarkMode ? buildDarkTheme() : buildLightTheme();
    
    // Only apply text scaling if it's different from 1.0 to avoid Flutter assertion errors
    if (textScaleFactor != 1.0) {
      return baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          bodyColor: baseTheme.textTheme.bodyLarge?.color,
          displayColor: baseTheme.textTheme.headlineLarge?.color,
          fontSizeFactor: textScaleFactor,
        ),
      );
    }
    
    // Return base theme without modification if text scale is 1.0
    return baseTheme;
  }
}
