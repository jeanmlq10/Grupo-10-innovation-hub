import 'package:flutter/material.dart';

/// Catálogo de iconos para la foto de perfil. Roble no guarda imágenes,
/// así que en `user_profiles.avatarIcon` se guarda solo la clave.
abstract final class AvatarIcons {
  static const Map<String, IconData> all = {
    'person': Icons.person_rounded,
    'face': Icons.face_rounded,
    'smile': Icons.emoji_emotions_rounded,
    'school': Icons.school_rounded,
    'code': Icons.code_rounded,
    'palette': Icons.palette_rounded,
    'science': Icons.science_rounded,
    'campaign': Icons.campaign_rounded,
    'lightbulb': Icons.lightbulb_rounded,
    'rocket': Icons.rocket_launch_rounded,
    'eco': Icons.eco_rounded,
    'music': Icons.music_note_rounded,
    'sports': Icons.sports_soccer_rounded,
    'camera': Icons.photo_camera_rounded,
    'pets': Icons.pets_rounded,
    'star': Icons.star_rounded,
  };

  /// null si [key] está vacío o no existe (se muestra la inicial).
  static IconData? of(String? key) =>
      key == null || key.isEmpty ? null : all[key];
}
