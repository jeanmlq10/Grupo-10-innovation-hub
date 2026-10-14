import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/time_ago.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/ui/widgets/notification_labels.dart';

/// Una fila de la lista de notificaciones: icono del tipo, título, mensaje,
/// "Hace 2 h" y el punto morado si no se ha leído.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final negative = NotificationLabels.isNegative(notification.type);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: notification.read
              ? Colors.white
              : HomeColors.navSelectedBackground.withValues(alpha: 0.35),
          border: Border.all(color: HomeColors.borderGrey),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: negative
                    ? const Color(0xFFFDE8E8)
                    : HomeColors.navSelectedBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                NotificationLabels.typeIcon(notification.type),
                color: negative
                    ? const Color(0xFFD9534F)
                    : HomeColors.primaryPurple,
                size: 21,
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
                      fontSize: 14,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: HomeColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeAgo(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration: const BoxDecoration(
                  color: HomeColors.primaryPurple,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
