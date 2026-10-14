import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/ui/views/project_detail_page.dart';
import 'package:f_clean_template/features/projects/ui/widgets/project_card.dart';

/// "Proyectos en los que ha participado" una persona (solo participaciones
/// registradas por el creador de cada proyecto).
class UserParticipationsPage extends StatefulWidget {
  const UserParticipationsPage({
    super.key,
    required this.userId,
    required this.name,
  });

  final String userId;
  final String name;

  @override
  State<UserParticipationsPage> createState() => _UserParticipationsPageState();
}

class _UserParticipationsPageState extends State<UserParticipationsPage> {
  final ProfileController _controller = Get.find();
  late final Future<List<Project>> _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.participationsOf(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('Proyectos de ${widget.name}'),
      ),
      body: FutureBuilder<List<Project>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(errorMessage(snapshot.error!)));
          }
          final projects = snapshot.data ?? const <Project>[];
          if (projects.isEmpty) {
            return const Center(
              child: Text(
                'Todavía no ha participado en proyectos.',
                style: TextStyle(color: HomeColors.textSecondary),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: projects.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => ProjectCard(
              project: projects[index],
              onTap: () => Get.to(
                () => ProjectDetailPage(project: projects[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
