import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/domain/models/project.dart';
import '../../../home/ui/home_colors.dart';
import '../widgets/participation_option_tile.dart';
import '../widgets/project_comments_sheet.dart';
import 'available_tasks_page.dart';
import 'join_team_page.dart';

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
                onTap: () =>
                    Get.to(() => AvailableTasksPage(project: widget.project)),
              ),
              ParticipationOptionTile(
                icon: Icons.groups_outlined,
                title: 'Unirme al equipo',
                subtitle: 'Forma parte del equipo a largo plazo.',
                onTap: () =>
                    Get.to(() => JoinTeamPage(project: widget.project)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
