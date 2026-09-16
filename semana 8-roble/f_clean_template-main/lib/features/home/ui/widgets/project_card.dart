import 'package:flutter/material.dart';

import '../../domain/models/project.dart';
import '../home_colors.dart';
import 'dashed_border.dart';

/// Card for a single [Project] in the "Explorar proyectos" feed.
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final Project project;
  final VoidCallback? onTap;

  static const Map<String, IconData> _categoryIcons = {
    'Medio ambiente': Icons.eco_outlined,
    'Impacto social': Icons.groups_outlined,
    'Innovación': Icons.lightbulb_outline,
    'Tecnología': Icons.memory_outlined,
    'Educación': Icons.school_outlined,
    'Comunidad': Icons.diversity_3_outlined,
  };

  IconData get _leadingIcon {
    for (final category in project.categories) {
      final icon = _categoryIcons[category];
      if (icon != null) return icon;
    }
    // Every project — example or user-created — gets the same generic
    // icon treatment already used elsewhere in the app (Mis proyectos,
    // Ver proyecto) instead of a grey placeholder box.
    return Icons.eco_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomeColors.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCEFE1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _leadingIcon,
                      color: const Color(0xFF3E8E5C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name.isEmpty ? '(Sin nombre)' : project.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          project.description.isEmpty
                              ? 'Sin descripción todavía.'
                              : project.description,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: HomeColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (project.categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: project.categories
                      .map((category) => _CategoryChip(
                            label: category,
                            icon: _categoryIcons[category] ?? Icons.label_outline,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: Colors.black87,
      strokeWidth: 1.2,
      gap: 3,
      radius: 20,
      dotted: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: HomeColors.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: HomeColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
