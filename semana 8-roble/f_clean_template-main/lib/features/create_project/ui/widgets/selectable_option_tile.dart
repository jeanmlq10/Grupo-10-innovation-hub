import 'package:flutter/material.dart';

import '../../../home/ui/home_colors.dart';

/// A single-choice option card: icon, title, subtitle, and a check mark
/// (or empty ring) on the right showing whether it's selected. Used for
/// both "Tiempo estimado" (Días/Semanas/Meses/Años) and "Audiencia"
/// (Solo yo/Toda la comunidad) — the two steps where the user picks
/// exactly one option from a short list.
class SelectableOptionTile extends StatelessWidget {
  const SelectableOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

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
            Icon(icon, color: HomeColors.primaryPurple, size: 22),
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
            if (selected)
              const Icon(
                Icons.check_circle,
                color: HomeColors.primaryPurple,
                size: 20,
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: HomeColors.borderGrey, width: 1.4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
