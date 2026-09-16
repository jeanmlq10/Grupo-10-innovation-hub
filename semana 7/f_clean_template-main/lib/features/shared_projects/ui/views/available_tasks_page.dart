import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../create_project/ui/widgets/selectable_option_tile.dart';
import '../../../home/domain/models/project.dart';
import '../../../home/ui/home_colors.dart';
import 'join_team_page.dart';

/// "Tareas disponibles" — the tasks offered here are exactly the roles
/// the creator asked for in "Equipo necesario" (`project.teamRoles`),
/// never invented data. Reuses [SelectableOptionTile] from
/// `create_project` since it's the same "pick exactly one" interaction
/// already used for "Tiempo estimado"/"Audiencia".
class AvailableTasksPage extends StatefulWidget {
  const AvailableTasksPage({super.key, required this.project});

  final Project project;

  @override
  State<AvailableTasksPage> createState() => _AvailableTasksPageState();
}

class _AvailableTasksPageState extends State<AvailableTasksPage> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final roles = widget.project.teamRoles.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back, color: HomeColors.textPrimary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tareas disponibles',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Elige en cuál quieres ayudar',
                style: TextStyle(fontSize: 14.5, color: HomeColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: roles.isEmpty
                    ? const Center(
                        child: Text(
                          'Este proyecto no especificó tareas todavía.',
                          style: TextStyle(color: HomeColors.textSecondary),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            for (final role in roles)
                              SelectableOptionTile(
                                icon: Icons.task_alt_outlined,
                                title: role,
                                subtitle: 'Tarea abierta del equipo necesario',
                                selected: _selectedRole == role,
                                onTap: () =>
                                    setState(() => _selectedRole = role),
                              ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedRole == null) {
                      Get.snackbar(
                        'Elige una tarea',
                        'Selecciona en cuál tarea quieres ayudar.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    Get.to(
                      () => JoinTeamPage(
                        project: widget.project,
                        initialRole: _selectedRole,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
