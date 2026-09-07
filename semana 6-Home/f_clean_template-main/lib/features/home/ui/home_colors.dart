import 'package:flutter/material.dart';

/// Colors specific to the Home / "Explorar proyectos" screen, matching the
/// Figma prototype. Kept local to this feature instead of touching
/// `core/app_theme.dart`, so the rest of the template (auth, product,
/// yellowM3 scheme) is not affected by this delivery.
abstract final class HomeColors {
  /// Icon stroke color across the bottom navigation (sampled from Figma:
  /// #4B309E).
  static const Color primaryPurple = Color(0xFF4B309E);

  /// Solid fill of the "+" circle in the "Crea otra idea" card (#634AAA).
  static const Color circlePurple = Color(0xFF634AAA);

  /// Background of the "Crea otra idea" card (#B5AAD7).
  static const Color ideaCardBackground = Color(0xFFB5AAD7);

  /// Light lavender behind the selected bottom-nav icon (#E4E0F0).
  static const Color navSelectedBackground = Color(0xFFE4E0F0);

  /// Blue underline accent under each project title (sampled from Figma —
  /// intentionally blue, not purple).
  static const Color titleAccentBlue = Color(0xFF3F8AE2);

  static const Color surfaceGrey = Color(0xFFF2F2F5);
  static const Color placeholderGrey = Color(0xFFD9D9DE);
  static const Color borderGrey = Color(0xFFE3E3E8);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6F);
}
