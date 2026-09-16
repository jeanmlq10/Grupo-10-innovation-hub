import 'package:flutter/material.dart';

import '../../../home/ui/home_colors.dart';

/// One row of "Elige cómo participar": icon, title, subtitle and a
/// chevron — unlike `SelectableOptionTile` (create_project), this
/// navigates immediately on tap instead of toggling a selection.
///
/// [selected] is only used by "Seguir", to reflect that the project is
/// already followed (purple border + check instead of the chevron) —
/// the same "selected" visual language already used elsewhere in the
/// app, per this stage's own instruction to reuse it.
class ParticipationOptionTile extends StatelessWidget {
  const ParticipationOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? HomeColors.navSelectedBackground : Colors.white,
          border: Border.all(
            color: selected ? HomeColors.primaryPurple : HomeColors.borderGrey,
            width: selected ? 1.6 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: HomeColors.navSelectedBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: HomeColors.primaryPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.chevron_right,
              color: selected
                  ? HomeColors.primaryPurple
                  : HomeColors.textSecondary,
              size: selected ? 20 : 22,
            ),
          ],
        ),
      ),
    );
  }
}
