import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/error_message.dart';
import '../../../home/ui/home_colors.dart';
import '../../domain/models/app_notification.dart';
import '../viewmodels/project_application_controller.dart';
import 'project_detail_page.dart';
import 'requests_page.dart';

/// "Notificaciones" — reachable from the bottom navigation bar. Reads the
/// user's notifications from Roble (new requests, accepted/rejected
/// requests, comments). Tapping one marks it read and opens "Solicitudes"
/// (new requests) or the project.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ProjectApplicationController _controller = Get.find();
  late Future<List<AppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.notifications();
  }

  Future<void> _open(AppNotification notification) async {
    if (!notification.read) {
      try {
        await _controller.markNotificationRead(notification.id);
      } catch (_) {
        // Not being able to mark it read must not block opening it.
      }
    }
    if (notification.type == AppNotificationType.newRequest) {
      await Get.to(() => const RequestsPage());
    } else if (notification.projectId.isNotEmpty) {
      final project = await _controller.projectById(notification.projectId);
      if (project != null) {
        await Get.to(() => ProjectDetailPage(project: project));
      }
    }
    if (mounted) setState(() => _future = _controller.notifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
              const SizedBox(height: 8),
              const Text(
                'Notificaciones',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<AppNotification>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final notifications =
                        snapshot.data ?? const <AppNotification>[];
                    if (snapshot.hasError || notifications.isEmpty) {
                      return Center(
                        child: Text(
                          snapshot.hasError
                              ? errorMessage(snapshot.error!)
                              : 'Todavía no tienes notificaciones.',
                          style: const TextStyle(
                            color: HomeColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        final next = _controller.notifications();
                        setState(() => _future = next);
                        await next;
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: notifications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _NotificationTile(
                          notification: notifications[index],
                          onTap: () => _open(notifications[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon => switch (notification.type) {
    AppNotificationType.requestAccepted => Icons.check_circle_outline,
    AppNotificationType.requestRejected => Icons.cancel_outlined,
    AppNotificationType.newComment => Icons.chat_bubble_outline,
    AppNotificationType.memberJoined => Icons.group_add_outlined,
    _ => Icons.person_add_alt_1,
  };

  String get _timeLabel {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1) return 'Justo ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.read
              ? Colors.white
              : HomeColors.navSelectedBackground.withValues(alpha: 0.45),
          border: Border.all(color: HomeColors.borderGrey),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: HomeColors.navSelectedBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                color: HomeColors.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: HomeColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeLabel,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
