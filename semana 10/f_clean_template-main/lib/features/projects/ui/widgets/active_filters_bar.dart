import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';

/// Fila bajo el buscador con los filtros activos ("Diseñador ▾",
/// "Últimos 30 días ▾"...). Tocar una etiqueta abre "Filtros"; "Limpiar"
/// los quita todos. Solo presentación: recibe los textos ya armados.
class ActiveFiltersBar extends StatelessWidget {
  const ActiveFiltersBar({
    super.key,
    required this.labels,
    required this.onOpenFilters,
    required this.onClear,
  });

  final List<String> labels;
  final VoidCallback onOpenFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final label in labels)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: HomeColors.flowLavender,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onOpenFilters,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: HomeColors.flowPurple,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: HomeColors.flowPurple,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              foregroundColor: HomeColors.flowSlate,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}
