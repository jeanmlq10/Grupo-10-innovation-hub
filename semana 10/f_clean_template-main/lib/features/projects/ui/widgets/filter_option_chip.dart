import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';

/// Una opción del panel "Filtros" (ej. "Últimos 7 días").
/// Seleccionada: fondo lavanda con borde morado. Solo presentación.
class FilterOptionChip extends StatelessWidget {
  const FilterOptionChip({
    super.key,
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
      color: selected ? HomeColors.flowLavender : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? HomeColors.flowPurple : HomeColors.flowBorder,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!selected) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: HomeColors.flowHint,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? HomeColors.flowPurple : HomeColors.flowTabText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
