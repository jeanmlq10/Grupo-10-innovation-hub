import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../create_project/ui/widgets/selectable_option_tile.dart';
import '../../../home/domain/models/project.dart';
import '../../../../core/error_message.dart';
import '../../../home/ui/home_colors.dart';
import '../../domain/models/project_task.dart';
import '../viewmodels/project_application_controller.dart';
import 'join_team_page.dart';

/// "Tareas disponibles" — the project's specific tasks with free spots,
/// loaded from Roble (`project_tasks`). They are NOT the team roles: those
/// are chosen in "Unirme al equipo". Reuses [SelectableOptionTile] from
/// `create_project` since it's the same "pick exactly one" interaction
/// already used for "Tiempo estimado"/"Audiencia".
class AvailableTasksPage extends StatefulWidget {
  const AvailableTasksPage({super.key, required this.project});

  final Project project;

  @override
  State<AvailableTasksPage> createState() => _AvailableTasksPageState();
}

class _AvailableTasksPageState extends State<AvailableTasksPage> {
  final ProjectApplicationController _controller = Get.find();
  late final Future<List<ProjectTask>> _tasksFuture;
  ProjectTask? _selectedTask;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _controller
        .tasksFor(widget.project.id)
        .then((tasks) => tasks.where((task) => task.hasSpots).toList());
  }

  @override
  Widget build(BuildContext context) {

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
                icon: const Icon(
                  Icons.arrow_back,
                  color: HomeColors.textPrimary,
                ),
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
                style: TextStyle(
                  fontSize: 14.5,
                  color: HomeColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<ProjectTask>>(
                  future: _tasksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final tasks = snapshot.data ?? const <ProjectTask>[];
                    if (snapshot.hasError || tasks.isEmpty) {
                      return Center(
                        child: Text(
                          snapshot.hasError
                              ? errorMessage(snapshot.error!)
                              : 'Este proyecto no tiene tareas disponibles.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: HomeColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final task in tasks)
                            SelectableOptionTile(
                              icon: Icons.task_alt_outlined,
                              title: task.title,
                              subtitle:
                                  'Se necesitan ${task.numberNeeded - task.numberAccepted}',
                              selected: _selectedTask?.id == task.id,
                              onTap: () => setState(() => _selectedTask = task),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedTask == null) {
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
                        task: _selectedTask,
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
