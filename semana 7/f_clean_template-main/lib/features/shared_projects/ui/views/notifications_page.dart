import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/repositories/i_shared_projects_repository.dart';
import 'requests_page.dart';

/// "Notificaciones" — reachable from the bottom navigation bar. Only one
/// kind of notification exists this stage: "someone applied to your
/// project". Tapping any of them opens "Solicitudes", where the actual
/// accept/reject decision happens.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = Get.find<ISharedProjectsRepository>()
        .getNotifications();

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
                icon: const Icon(Icons.arrow_back, color: HomeColors.textPrimary),
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
                child: notifications.isEmpty
                    ? const Center(
                        child: Text(
                          'Todavía no tienes notificaciones.',
                          style: TextStyle(color: HomeColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _NotificationTile(notification: notifications[index]),
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
  const _NotificationTile({required this.notification});

  final AppNotification notification;

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
      onTap: () => Get.to(() => const RequestsPage()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
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
              child: const Icon(
                Icons.person_add_alt_1,
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
