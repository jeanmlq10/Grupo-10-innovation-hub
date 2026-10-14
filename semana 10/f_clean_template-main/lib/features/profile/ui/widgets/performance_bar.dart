import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';

/// Barra de "Tu desempeño" (Colaboración 90 %...).
class PerformanceBar extends StatelessWidget {
  const PerformanceBar({super.key, required this.label, required this.value});

  final String label;

  /// Entre 0 y 1.
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13.5, color: HomeColors.textPrimary),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: HomeColors.navSelectedBackground,
                color: HomeColors.primaryPurple,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: HomeColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
