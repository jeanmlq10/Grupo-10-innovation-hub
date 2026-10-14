import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';

/// Cabecera de los detalles de notificación: avatar, nombre en negrita y
/// las líneas de qué hizo ("quiere unirse a tu proyecto", "EcoCampus") y
/// cuándo.
class PersonHeader extends StatelessWidget {
  const PersonHeader({
    super.key,
    required this.name,
    required this.lines,
    this.time,
    this.icon = Icons.person_outline,
  });

  final String name;
  final List<String> lines;
  final String? time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: HomeColors.navSelectedBackground,
            shape: BoxShape.circle,
            border: Border.all(color: HomeColors.borderGrey),
          ),
          child: Icon(icon, size: 38, color: HomeColors.primaryPurple),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: HomeColors.textPrimary,
          ),
        ),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              line,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: HomeColors.textPrimary,
              ),
            ),
          ),
        if (time != null) ...[
          const SizedBox(height: 6),
          Text(
            time!,
            style: const TextStyle(
              fontSize: 12,
              color: HomeColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
