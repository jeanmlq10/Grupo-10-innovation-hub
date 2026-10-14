import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/time_ago.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/ui/viewmodels/notifications_controller.dart';
import 'package:f_clean_template/features/notifications/ui/widgets/person_header.dart';
import 'package:f_clean_template/features/notifications/ui/widgets/quote_box.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/ui/views/project_detail_page.dart';

/// "Comentario" y "Tarea completada" (Página 4.3, pantallas 6 y 7): quién,
/// qué hizo, en qué proyecto o tarea, y el botón para verlo.
class ActivityNotificationPage extends StatefulWidget {
  const ActivityNotificationPage({super.key, required this.notification});

  final AppNotification notification;

  @override
  State<ActivityNotificationPage> createState() =>
      _ActivityNotificationPageState();
}

class _ActivityNotificationPageState extends State<ActivityNotificationPage> {
  final NotificationsController _controller = Get.find();
  late final Future<Project?> _project;

  AppNotification get _n => widget.notification;
  bool get _isComment => _n.type == AppNotificationType.newComment;

  @override
  void initState() {
    super.initState();
    _project = _controller.projectById(_n.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Project?>(
          future: _project,
          builder: (context, snapshot) {
            final project = snapshot.data;
            final projectName = project?.name ?? 'el proyecto';
            final detail = _n.detail ?? '';
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  PersonHeader(
                    icon: _isComment
                        ? Icons.person_outline
                        : Icons.check_box_outlined,
                    name: _n.actorName ?? 'Alguien',
                    lines: _isComment
                        ? ['comentó en el proyecto', projectName]
                        : ['completó la tarea', detail],
                    time: timeAgo(_n.createdAt),
                  ),
                  const SizedBox(height: 24),
                  if (_isComment)
                    QuoteBox(text: detail.isEmpty ? _n.message : detail)
                  else
                    QuoteBox(text: _n.message),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: project == null
                          ? null
                          : () => Get.off(
                              () => ProjectDetailPage(project: project),
                            ),
                      style: FilledButton.styleFrom(
                        backgroundColor: HomeColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_isComment ? 'Ver proyecto' : 'Ver tarea'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
