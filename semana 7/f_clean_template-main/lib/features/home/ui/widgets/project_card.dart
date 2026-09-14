import 'package:flutter/material.dart';

import '../../domain/models/project.dart';
import '../home_colors.dart';
import 'dashed_border.dart';

/// Card for a single [Project] in the "Explorar proyectos" feed.
///
/// Note: in the Figma prototype only the first card (EcoCampus) is drawn
/// in full detail; the ones below it are low-fidelity placeholders (a
/// grey box + grey bars). This widget renders every project with the one
/// fully-specified style so the whole list stays legible and consistent.
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

  IconData _iconFor(String category) =>
      _categoryIcons[category] ?? Icons.label_outline;

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
              _UnderlinedTitle(text: project.name),
              const SizedBox(height: 6),
              Text(
                project.description,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: HomeColors.textPrimary,
                  height: 1.3,
                ),
              ),
              if (project.categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: project.categories
                      .map((category) => _CategoryChip(
                            label: category,
                            icon: _iconFor(category),
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

/// Renders the project name with the short underline accent stroke seen
/// under "EcoCampus" in the prototype.
class _UnderlinedTitle extends StatelessWidget {
  const _UnderlinedTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 2,
          right: 2,
          bottom: 3,
          child: Container(height: 3, color: HomeColors.titleAccentBlue),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: HomeColors.textPrimary,
            ),
          ),
        ),
      ],
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
