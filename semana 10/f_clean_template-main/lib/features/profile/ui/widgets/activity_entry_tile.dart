import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/time_ago.dart';
import 'package:f_clean_template/features/profile/domain/models/activity_entry.dart';
import 'package:f_clean_template/features/profile/ui/widgets/profile_labels.dart';

/// Un registro del historial: icono, qué pasó, el proyecto y cuándo.
class ActivityEntryTile extends StatelessWidget {
  const ActivityEntryTile({
    super.key,
    required this.entry,
    required this.self,
    this.onTap,
  });

  final ActivityEntry entry;

  final bool self;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = entry.detail == null || entry.kind == ActivityKind.comment
        ? entry.projectName
        : '${entry.projectName} · ${entry.detail}';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              ProfileLabels.activityIcon(entry.kind),
              color: HomeColors.primaryPurple,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ProfileLabels.activityTitle(entry.kind, self: self),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (entry.date != null)
              Text(
                timeAgo(entry.date!),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: HomeColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
