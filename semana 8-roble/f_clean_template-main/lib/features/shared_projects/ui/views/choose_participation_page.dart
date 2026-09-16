import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/domain/models/project.dart';
import '../../../home/ui/home_colors.dart';
import '../../domain/repositories/i_shared_projects_repository.dart';
import '../widgets/participation_option_tile.dart';
import 'available_tasks_page.dart';
import 'join_team_page.dart';

/// "Elige cómo participar" — reached from "Opciones del proyecto" on
/// "Ver proyecto". Each option does something different on purpose:
/// - "Seguir" toggles a real, persisted follow state (see
///   `ISharedProjectsRepository.toggleFollow`) — it does NOT navigate
///   anywhere, it just updates in place, same as any other toggle.
/// - "Comentar" is explicitly out of scope for now and just says so.
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
  final ISharedProjectsRepository repository = Get.find();
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = repository.isFollowing(widget.project.id);
  }

  void _toggleFollow() {
    repository.toggleFollow(widget.project.id);
    setState(() => _isFollowing = repository.isFollowing(widget.project.id));
    Get.snackbar(
      _isFollowing ? 'Ahora sigues este proyecto' : 'Dejaste de seguir',
      _isFollowing
          ? 'Recibirás novedades de "${widget.project.name}".'
          : 'Ya no verás este proyecto en "Seguidos".',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _comingSoon(String title) {
    Get.snackbar(
      title,
      'Esta opción llega en una próxima entrega.',
      snackPosition: SnackPosition.BOTTOM,
    );
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
                title: _isFollowing ? 'Siguiendo' : 'Seguir',
                subtitle: _isFollowing
                    ? 'Ya recibes novedades de este proyecto.'
                    : 'Recibe novedades del proyecto.',
                selected: _isFollowing,
                onTap: _toggleFollow,
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
                onTap: () =>
                    Get.to(() => AvailableTasksPage(project: widget.project)),
              ),
              ParticipationOptionTile(
                icon: Icons.groups_outlined,
                title: 'Unirme al equipo',
                subtitle: 'Forma parte del equipo a largo plazo.',
                onTap: () => Get.to(() => JoinTeamPage(project: widget.project)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
