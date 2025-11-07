import 'package:flutter/material.dart';
// Removed GoogleFonts to simplify iOS startup; using bundled Rubik font

/// HEAVYWEIGHT theme constants and styles
/// Embodies the mandate philosophy: brutal, honest, uncompromising
class HeavyweightTheme {
  // Colors
  static const Color background = Color(0xFF111111); // Near black
  static const Color surface = Color(0xFF222222); // Slightly lighter
  static const Color primary = Colors.white; // Pure white
  static const Color secondary = Color(0xFF444444); // Dark gray
  static const Color surfaceLight = Color(0xFFF7F7FA); // Soft neutral background
  static const Color card = Color(0xFFFFFFFF); // Light card surface
  static const Color stroke = Color(0xFFE5E6EB); // Subtle border
  static const Color accentNeon = Color(0xFF5FFB7F); // Progress accent
  static const Color danger = Color(0xFFFF4444); // Red for violations
  static const Color warning = Color(0xFFFFAA00); // Amber for excess
  static const Color success = Colors.white; // White for mandate

  // Additional colors for compatibility
  static const Color textSecondary = Color(0xFF888888);
  static const Color textPrimary = Colors.white; // Alias for primary text color
  static const Color accent = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFFF4444);
  static const Color errorSurface = Color(0xFF331111);
  static const Color onPrimary = Color(0xFF111111);
  static const Color textDisabled = Color(0xFF666666);

  // Spacing (in pixels)
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 40.0;
  static const double spacingXxxl = 48.0;
  static const double spacingCalendarPill = 18.0;

  // Layout breakpoints (logical pixels)
  static const double breakpointTablet = 600.0;
  static const double breakpointDesktop = 900.0;
  static const double contentMaxWidth = 720.0;

  // Button dimensions (accessibility compliant)
  static const double buttonHeight =
      60.0; // Large buttons - exceeds requirements
  static const double buttonHeightMedium =
      48.0; // Medium buttons - meets Android standard
  static const double buttonHeightSmall =
      44.0; // Small buttons - meets iOS standard

  // Typography
  static final TextStyle h1 = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 2.5,
    height: 1.2,
  );

  static final TextStyle timerDisplay = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 96,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 4,
  );

  static final TextStyle h2 = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 2,
    height: 1.3,
  );

  static final TextStyle h3 = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 1.5,
    height: 1.4,
  );

  static final TextStyle h4 = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 1.25,
    height: 1.4,
  );

  static final TextStyle bodyLarge = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: primary,
    letterSpacing: 1,
    height: 1.5,
  );

  static final TextStyle bodyMedium = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: primary,
    letterSpacing: 0.75,
    height: 1.5,
  );

  static final TextStyle bodySmall = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: secondary,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static final TextStyle caption = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 1.5,
    height: 1.2,
  );

  static final TextStyle labelLarge = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 1.5,
    height: 1.2,
  );

  static final TextStyle labelMedium = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 0.75,
    height: 1.2,
  );

  static final TextStyle labelSmall = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: secondary,
    letterSpacing: 1,
    height: 1.1,
  );

  // Button styles
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: background,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
        textStyle: labelMedium,
        minimumSize: const Size(double.infinity, 60),
        padding: const EdgeInsets.symmetric(horizontal: spacingLg),
      );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 2),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: labelMedium,
        minimumSize: const Size(double.infinity, 60),
        padding: const EdgeInsets.symmetric(horizontal: spacingLg),
      );

  static ButtonStyle get dangerButton => ElevatedButton.styleFrom(
        backgroundColor: danger,
        foregroundColor: primary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
        textStyle: labelMedium,
        minimumSize: const Size(double.infinity, 60),
        padding: const EdgeInsets.symmetric(horizontal: spacingLg),
      );

  // Card decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        border: Border.all(color: secondary),
        color: background,
      );

  static BoxDecoration get cardDecorationActive => BoxDecoration(
        border: Border.all(color: primary, width: 2),
        color: surface,
      );

  static BoxDecoration get accentCardDecoration => BoxDecoration(
        border: Border.all(color: accent),
        color: surface,
      );
}
