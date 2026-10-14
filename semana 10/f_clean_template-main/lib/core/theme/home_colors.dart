import 'package:flutter/material.dart';

/// Colors specific to the Home / "Explorar proyectos" screen, matching the
/// Figma prototype. Kept local to this feature instead of touching
/// `core/app_theme.dart`, so the rest of the template (auth, product,
/// yellowM3 scheme) is not affected by this delivery.
abstract final class HomeColors {
  static const Color primaryPurple = Color(0xFF4B309E);

  static const Color circlePurple = Color(0xFF634AAA);

  static const Color ideaCardBackground = Color(0xFFB5AAD7);

  static const Color navSelectedBackground = Color(0xFFE4E0F0);

  static const Color titleAccentBlue = Color(0xFF3F8AE2);

  static const Color surfaceGrey = Color(0xFFF2F2F5);
  static const Color placeholderGrey = Color(0xFFD9D9DE);
  static const Color borderGrey = Color(0xFFE3E3E8);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6F);

  static const Color flowPurple = Color(0xFF4B309E);

  static const Color flowAccent = Color(0xFF4B309E);

  static const Color flowNavy = Color(0xFF16153F);

  static const Color flowSlate = Color(0xFF5E6285);

  static const Color flowHint = Color(0xFFA9AAAD);

  static const Color flowBorder = Color(0xFFE4E4E7);

  static const Color flowFieldFill = Color(0xFFEFEFF0);
  static const Color flowFieldBorder = Color(0xFFD2D3D7);
  static const Color flowFieldHint = Color(0xFF7E8084);

  static const Color flowSoftPurple = Color(0xFFB9A6F6);

  static const Color flowLavender = Color(0xFFECE8FD);

  static const Color flowLavenderFaint = Color(0xFFF6F4FE);

  static const Color flowBackCircle = Color(0xFFF1F1F4);

  static const Color flowGreen = Color(0xFF10A052);

  static const Color flowFootnote = Color(0xFF8D8A98);

  static const Color flowMeta = Color(0xFF7C7E92);
  static const Color flowDescription = Color(0xFF6F7293);
  static const Color flowTabGrey = Color(0xFFF1F1F5);
  static const Color flowTabText = Color(0xFF666483);
  static const Color flowSearchFill = Color(0xFFEEEDF2);
  static const Color flowSearchHint = Color(0xFF717694);
  static const Color flowEmpty = Color(0xFF898CA3);

  static const Color flowIdeaCard = Color(0xFFDED4FD);
  static const Color flowIdeaDash = Color(0xFFC8B8F4);
  static const Color flowIdeaPlus = Color(0xFF7E5EDF);
}
