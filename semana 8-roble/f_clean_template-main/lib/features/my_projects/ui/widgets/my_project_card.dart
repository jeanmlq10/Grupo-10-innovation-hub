import 'package:flutter/material.dart';

import '../../../home/ui/home_colors.dart';
import '../../domain/models/my_project.dart';

/// Fully-specified card for a [MyProject] — used for any published
/// project the user created and its full stats.
///
/// The stats row (Miembros / Tareas / Solicitudes) only renders when the
/// project actually has those counters, since a fresh draft doesn't have
/// them yet.
class MyProjectCard extends StatelessWidget {
  const MyProjectCard({super.key, required this.project, this.onTap, this.onEdit});

  final MyProject project;
  final VoidCallback? onTap;

  /// Shows the three-dot menu with "Editar proyecto" when provided.
  /// `null` keeps the dot purely decorative (used for non-editable
  /// example/seed cards, if any ever exist again).
  final VoidCallback? onEdit;

  bool get _hasStats =>
      project.membersCount != null ||
      project.tasksCount != null ||
      project.requestsCount != null;

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
                    child: const Icon(
                      Icons.eco_outlined,
                      color: Color(0xFF3E8E5C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: HomeColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: HomeColors.textSecondary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      onSelected: (_) => onEdit?.call(),
                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Editar proyecto'),
                        ),
                      ],
                    )
                  else
                    const Icon(
                      Icons.more_vert,
                      color: HomeColors.textSecondary,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _StatusChip(status: project.status),
              if (_hasStats) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(value: project.membersCount, label: 'Miembros'),
                    _Stat(value: project.tasksCount, label: 'Tareas'),
                    _Stat(value: project.requestsCount, label: 'Solicitudes'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HomeColors.navSelectedBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: HomeColors.primaryPurple,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value ?? 0}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: HomeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: HomeColors.textSecondary),
        ),
      ],
    );
  }
}
