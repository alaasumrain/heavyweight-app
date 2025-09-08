import 'package:flutter/material.dart';

/// HEAVYWEIGHT theme constants and styles
/// Embodies the mandate philosophy: brutal, honest, uncompromising
class HeavyweightTheme {
  
  // Colors
  static const Color background = Color(0xFF111111);  // Near black
  static const Color surface = Color(0xFF222222);     // Slightly lighter
  static const Color primary = Colors.white;          // Pure white
  static const Color secondary = Color(0xFF444444);   // Dark gray
  static const Color danger = Color(0xFFFF4444);      // Red for violations
  static const Color warning = Color(0xFFFFAA00);     // Amber for excess
  static const Color success = Colors.white;          // White for mandate
  
  // Additional colors for compatibility
  static const Color textSecondary = Color(0xFF888888);
  static const Color textPrimary = Colors.white;  // Alias for primary text color
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

  // Button dimensions
  static const double buttonHeight = 60.0;
  static const double buttonHeightSmall = 48.0;
  
  // Typography
  static const TextStyle h1 = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 4,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 3,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 2,
    height: 1.4,
  );
  
  static const TextStyle h4 = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 1.5,
    height: 1.4,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: primary,
    letterSpacing: 1,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: primary,
    letterSpacing: 1,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: secondary,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 2,
    height: 1.2,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 1,
    height: 1.2,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'IBM Plex Mono',
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









