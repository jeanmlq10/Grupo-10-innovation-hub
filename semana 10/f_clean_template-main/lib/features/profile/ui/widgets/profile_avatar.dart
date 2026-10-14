import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/profile/ui/widgets/avatar_icons.dart';

/// Avatar redondo: el icono elegido en el perfil o, si no hay, la inicial.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.iconKey,
    this.size = 64,
  });

  final String name;

  /// Clave de [AvatarIcons] (`user_profiles.avatarIcon`).
  final String? iconKey;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = AvatarIcons.of(iconKey);
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HomeColors.navSelectedBackground,
        border: Border.all(color: HomeColors.borderGrey),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: size * 0.55, color: HomeColors.primaryPurple)
          : Text(
              initial,
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.bold,
                color: HomeColors.primaryPurple,
              ),
            ),
    );
  }
}
