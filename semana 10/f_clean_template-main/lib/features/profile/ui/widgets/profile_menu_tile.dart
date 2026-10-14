import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';

/// Fila de menú del perfil / configuración / privacidad: icono, título,
/// subtítulo opcional y flecha.
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFD9534F) : HomeColors.primaryPurple;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: HomeColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: HomeColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
