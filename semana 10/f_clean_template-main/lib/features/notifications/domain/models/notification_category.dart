import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';

/// Las categorías de "Filtrar notificaciones" (Página 4.1) y de las
/// preferencias de notificaciones del perfil. Dart puro.
enum NotificationCategory {
  participationRequests,
  taskApplications,
  completedTasks,
  comments,
  messages,
  mentions,
  platformNews,
  reminders;

  /// La categoría de un tipo de notificación. Las respuestas (aceptada /
  /// rechazada) van con lo que se pidió: equipo o tarea.
  static NotificationCategory ofType(String type) => switch (type) {
    AppNotificationType.taskApplication ||
    AppNotificationType.taskApplicationAccepted ||
    AppNotificationType.taskApplicationRejected =>
      NotificationCategory.taskApplications,
    AppNotificationType.taskCompleted => NotificationCategory.completedTasks,
    AppNotificationType.newComment => NotificationCategory.comments,
    AppNotificationType.newMessage => NotificationCategory.messages,
    _ => NotificationCategory.participationRequests,
  };

  /// Clave estable para guardarla en Roble (preferencias del perfil).
  String get key => name;

  static NotificationCategory? fromKey(String key) {
    for (final value in NotificationCategory.values) {
      if (value.key == key) return value;
    }
    return null;
  }
}
