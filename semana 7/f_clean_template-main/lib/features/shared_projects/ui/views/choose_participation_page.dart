import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/domain/models/project.dart';
import '../../../home/ui/home_colors.dart';
import '../widgets/participation_option_tile.dart';
import 'available_tasks_page.dart';
import 'join_team_page.dart';

/// "Elige cómo participar" — reached from "Aplicar al proyecto" on "Ver
/// proyecto". Of the four options, only "Postularme a una tarea" and
/// "Unirme al equipo" are wired to a real next step this stage; "Seguir"
/// and "Comentar" are explicitly out of scope for now (per the brief)
/// and just say so.
class ChooseParticipationPage extends StatelessWidget {
  const ChooseParticipationPage({super.key, required this.project});

  final Project project;

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
                icon: const Icon(Icons.arrow_back, color: HomeColors.textPrimary),
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
                icon: Icons.notifications_none,
                title: 'Seguir',
                subtitle: 'Recibe novedades del proyecto.',
                onTap: () => _comingSoon('Seguir'),
              ),
              ParticipationOptionTile(
                icon: Icons.chat_bubble_outline,
                title: 'Comentar',
                subtitle: 'Comparte ideas y dudas.',
                onTap: () => _comingSoon('Comentar'),
              ),
              ParticipationOptionTile(
                icon: Icons.task_alt_outlined,
                title: 'Postularme a una tarea',
                subtitle: 'Ayuda en una tarea específica.',
                onTap: () => Get.to(() => AvailableTasksPage(project: project)),
              ),
              ParticipationOptionTile(
                icon: Icons.groups_outlined,
                title: 'Unirme al equipo',
                subtitle: 'Forma parte del equipo a largo plazo.',
                onTap: () => Get.to(() => JoinTeamPage(project: project)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _comingSoon(String title) {
    Get.snackbar(
      title,
      'Esta opción llega en una próxima entrega.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
