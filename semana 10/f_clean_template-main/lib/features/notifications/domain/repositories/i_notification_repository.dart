import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';

/// Notificaciones persistentes (tabla `app_notifications`).
abstract class INotificationRepository {
  Future<List<AppNotification>> forUser(String userId);

  Future<void> send({
    required String recipientUserId,
    required String type,
    required String title,
    required String message,
    required String projectId,
    String? requestId,
    String? actorUserId,
    String? actorName,
    String? detail,
  });

  Future<void> markRead(String id);
}
