import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/date_format.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/project_detail_controller.dart';
import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';
import 'package:f_clean_template/features/requests/ui/widgets/participation_option_tile.dart';
import 'package:f_clean_template/features/comments/ui/widgets/project_comments_sheet.dart';
import 'package:f_clean_template/features/tasks/ui/views/available_tasks_page.dart';
import 'package:f_clean_template/features/requests/ui/views/join_team_page.dart';

/// "Elige cómo participar" — now a secondary menu, reached from the ⋮
/// button of "Ver proyecto". "Seguir" was removed from here: it lives in
/// the bell at the top right of "Ver proyecto".
/// - "Comentar" opens the same comments sheet as the "Comentar" button.
/// - "Postularme a una tarea" and "Unirme al equipo" open the real
///   request flow.
class ChooseParticipationPage extends StatefulWidget {
  const ChooseParticipationPage({super.key, required this.project});

  final Project project;

  @override
  State<ChooseParticipationPage> createState() =>
      _ChooseParticipationPageState();
}

class _ChooseParticipationPageState extends State<ChooseParticipationPage> {
  final ProjectDetailController _controller = Get.find();

  /// Tareas que aún reciben postulaciones (para mostrar su fecha límite).
  List<ProjectTask>? _openTasks;

  @override
  void initState() {
    super.initState();
    _controller
        .tasksFor(widget.project.id)
        .then((tasks) {
          if (!mounted) return;
          setState(
            () => _openTasks = tasks.where((t) => t.canApplyAt()).toList(),
          );
        })
        .catchError((Object _) {});
  }

  /// Cambio 2: "Disponible hasta" de las tareas (la fecha más lejana entre
  /// las abiertas).
  String? get _tasksFootnote {
    final open = _openTasks;
    if (open == null) return null;
    if (open.isEmpty) return 'No hay tareas disponibles ahora';
    final dates = open.map((t) => t.deadline).whereType<DateTime>().toList()
      ..sort();
    if (dates.isEmpty) return null;
    return 'Disponible hasta: ${formatShortDate(dates.last)}';
  }

  /// Cambio 2: "Convocatoria hasta" del equipo.
  String? get _teamFootnote {
    final project = widget.project;
    if (!project.isTeamCallOpenAt()) return 'Convocatoria cerrada';
    final deadline = project.teamDeadline;
    return deadline == null
        ? null
        : 'Convocatoria hasta: ${formatShortDate(deadline)}';
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
                'Elige cómo participar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ParticipationOptionTile(
                icon: Icons.chat_bubble_outline,
                title: 'Comentar',
                subtitle: 'Comparte ideas y dudas.',
                onTap: () => showProjectComments(context, widget.project.id),
              ),
              ParticipationOptionTile(
                icon: Icons.task_alt_outlined,
                title: 'Postularme a una tarea',
                subtitle: 'Ayuda en una tarea específica.',
                footnote: _tasksFootnote,
                onTap: () =>
                    Get.to(() => AvailableTasksPage(project: widget.project)),
              ),
              ParticipationOptionTile(
                icon: Icons.groups_outlined,
                title: 'Unirme al equipo',
                subtitle: 'Forma parte del equipo a largo plazo.',
                footnote: _teamFootnote,
                onTap: () {
                  if (!widget.project.isTeamCallOpenAt()) {
                    Get.snackbar(
                      'Convocatoria cerrada',
                      'La convocatoria para unirse al equipo ya cerró.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  Get.to(() => JoinTeamPage(project: widget.project));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
