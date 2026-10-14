import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/features/messages/ui/views/chat_page.dart';
import 'package:f_clean_template/features/profile/domain/models/public_profile.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/profile/ui/views/user_participations_page.dart';
import 'package:f_clean_template/features/profile/ui/widgets/activity_entry_tile.dart';
import 'package:f_clean_template/features/profile/ui/widgets/performance_bar.dart';
import 'package:f_clean_template/features/profile/ui/widgets/profile_avatar.dart';
import 'package:f_clean_template/features/profile/ui/widgets/trajectory_stats_grid.dart';

/// Perfil de otra persona: la evidencia de confiabilidad (trayectoria,
/// desempeño y actividad) que ve el creador antes de aceptarla. Respeta su
/// privacidad.
class PublicProfilePage extends StatefulWidget {
  const PublicProfilePage({super.key, required this.userId, required this.name});

  final String userId;
  final String name;

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final ProfileController _controller = Get.find();
  late final Future<PublicProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.publicProfile(widget.userId, fallbackName: widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text('Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<PublicProfile>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(errorMessage(snapshot.error!)));
          }
          final data = snapshot.data!;
          final p = data.profile;
          final isMe = widget.userId == _controller.session.loggedUser?.userId;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Center(
                child: ProfileAvatar(
                  name: p.name,
                  iconKey: p.avatarIcon,
                  size: 80,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                p.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              if (p.career.isNotEmpty)
                Text(
                  p.career,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: HomeColors.textSecondary),
                ),
              if (p.bio.isNotEmpty && data.canSeeDetails) ...[
                const SizedBox(height: 10),
                Text(
                  p.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: HomeColors.textPrimary),
                ),
              ],
              const SizedBox(height: 14),
              if (!isMe && p.acceptsMessages)
                OutlinedButton.icon(
                  onPressed: () => Get.to(
                    () => ChatPage(otherUserId: widget.userId, otherName: p.name),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Enviar mensaje'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HomeColors.primaryPurple,
                    side: const BorderSide(color: HomeColors.primaryPurple),
                  ),
                ),
              const SizedBox(height: 18),
              if (!data.canSeeDetails)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'Este perfil es privado: su trayectoria y actividad no '
                    'son visibles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HomeColors.textSecondary),
                  ),
                )
              else ...[
                const Text(
                  'Resumen de trayectoria',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TrajectoryStatsGrid(summary: data.summary!),
                const SizedBox(height: 16),
                const Text('Desempeño', style: TextStyle(fontWeight: FontWeight.bold)),
                PerformanceBar(label: 'Colaboración', value: data.summary!.collaboration),
                PerformanceBar(label: 'Cumplimiento', value: data.summary!.fulfillment),
                PerformanceBar(label: 'Calidad de aportes', value: data.summary!.quality),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Get.to(
                    () => UserParticipationsPage(userId: widget.userId, name: p.name),
                  ),
                  child: const Text('Proyectos en los que ha participado >'),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Actividad reciente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (data.activity.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Todavía no hay actividad.',
                      style: TextStyle(color: HomeColors.textSecondary),
                    ),
                  ),
                for (final entry in data.activity.take(10))
                  ActivityEntryTile(entry: entry, self: isMe),
              ],
            ],
          );
        },
      ),
    );
  }
}
