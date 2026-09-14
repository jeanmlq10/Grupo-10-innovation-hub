import 'package:flutter/material.dart';

import '../../../home/ui/home_colors.dart';

/// The "Mis proyectos (3)" / "Mis borradores (2)" segmented control right
/// below the subtitle. Purely presentational — [onSelectPublished] and
/// [onSelectDrafts] are the only way it reports a tap; tab-switch state
/// itself lives in `MyProjectsController`.
///
/// Reuses [HomeColors] from the home feature (not modified here) so the
/// purple/lavender palette matches the rest of the app exactly.
class MyProjectsTabs extends StatelessWidget {
  const MyProjectsTabs({
    super.key,
    required this.publishedCount,
    required this.draftsCount,
    required this.showingDrafts,
    required this.onSelectPublished,
    required this.onSelectDrafts,
  });

  final int publishedCount;
  final int draftsCount;
  final bool showingDrafts;
  final VoidCallback onSelectPublished;
  final VoidCallback onSelectDrafts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabChip(
            label: 'Mis proyectos ($publishedCount)',
            selected: !showingDrafts,
            onTap: onSelectPublished,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TabChip(
            label: 'Mis borradores ($draftsCount)',
            selected: showingDrafts,
            onTap: onSelectDrafts,
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? HomeColors.primaryPurple : HomeColors.surfaceGrey,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : HomeColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
