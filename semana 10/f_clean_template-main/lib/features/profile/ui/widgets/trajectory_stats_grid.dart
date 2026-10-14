import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/profile/domain/models/trajectory_summary.dart';
import 'package:f_clean_template/features/profile/ui/widgets/profile_labels.dart';

/// Los 4 indicadores del "Resumen de trayectoria" en una cuadrícula 2×2.
class TrajectoryStatsGrid extends StatelessWidget {
  const TrajectoryStatsGrid({super.key, required this.summary});

  final TrajectorySummary summary;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (Icons.folder_outlined, '${summary.projectsCompleted}', 'Proyectos\ncompletados'),
      (Icons.check_circle_outline, '${summary.tasksCompleted}', 'Tareas\ncompletadas'),
      (Icons.groups_outlined, '${summary.participations}', 'Participaciones\nen proyectos'),
      (
        Icons.bar_chart_rounded,
        ProfileLabels.commitment(summary.commitment),
        'Compromiso\nen la plataforma',
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: HomeColors.borderGrey),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (var row = 0; row < 2; row++)
            IntrinsicHeight(
              child: Row(
                children: [
                  for (var col = 0; col < 2; col++)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border(
                            right: col == 0
                                ? const BorderSide(color: HomeColors.borderGrey)
                                : BorderSide.none,
                            bottom: row == 0
                                ? const BorderSide(color: HomeColors.borderGrey)
                                : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              stats[row * 2 + col].$1,
                              color: HomeColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stats[row * 2 + col].$2,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: HomeColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    stats[row * 2 + col].$3,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: HomeColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
