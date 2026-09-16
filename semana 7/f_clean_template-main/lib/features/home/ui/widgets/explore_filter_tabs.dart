import 'package:flutter/material.dart';

import '../home_colors.dart';

/// The "Todos" / "Seguidos" segmented filter at the top of "Explorar
/// proyectos". Same visual pattern as `MyProjectsTabs` (filled purple
/// pill for the selected one, grey for the other) but without counts —
/// just two fixed options, nothing more.
class ExploreFilterTabs extends StatelessWidget {
  const ExploreFilterTabs({
    super.key,
    required this.showingFollowed,
    required this.onSelectAll,
    required this.onSelectFollowed,
  });

  final bool showingFollowed;
  final VoidCallback onSelectAll;
  final VoidCallback onSelectFollowed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterChip(
            label: 'Todos',
            selected: !showingFollowed,
            onTap: onSelectAll,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FilterChip(
            label: 'Seguidos',
            selected: showingFollowed,
            onTap: onSelectFollowed,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
