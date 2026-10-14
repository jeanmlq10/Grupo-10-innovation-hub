import 'package:f_clean_template/features/notifications/domain/models/notification_category.dart';

/// Kinds of notification the app sends (column `type` of `app_notifications`).
abstract final class AppNotificationType {
  /// Someone asked to join the team (owner receives it).
  static const String newRequest = 'new_request';

  /// Someone applied to a specific task (owner receives it).
  static const String taskApplication = 'task_application';

  /// Answers to whoever asked to join the team.
  static const String requestAccepted = 'request_accepted';
  static const String requestRejected = 'request_rejected';

  /// Answers to whoever applied to a task.
  static const String taskApplicationAccepted = 'task_application_accepted';
  static const String taskApplicationRejected = 'task_application_rejected';

  static const String newComment = 'new_comment';
  static const String taskCompleted = 'task_completed';
  static const String newMessage = 'new_message';
  static const String memberJoined = 'member_joined';

  /// Respuestas a quien pidió participar (4.2).
  static const Set<String> responses = {
    requestAccepted,
    requestRejected,
    taskApplicationAccepted,
    taskApplicationRejected,
  };

  /// Solicitudes que el creador puede aceptar o rechazar (4.3).
  static const Set<String> decidable = {newRequest, taskApplication};
}

/// A notification, stored in Roble (`app_notifications`), addressed to
/// [recipientUserId].
class AppNotification {
  const AppNotification({
    required this.id,
    required this.projectId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.type = AppNotificationType.newRequest,
    this.requestId,
    this.recipientUserId,
    this.read = false,
    this.actorUserId,
    this.actorName,
    this.detail,
  });

  final String id;
  final String? recipientUserId;
  final String projectId;
  final String? requestId;
  final String type;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  /// Quién causó el aviso (el que pidió unirse, comentó, completó...).
  /// Columna opcional `actorUserId`.
  final String? actorUserId;

  /// Nombre de quien causó el aviso (columna opcional `actorName`).
  final String? actorName;

  /// Dato extra según el tipo: el rol o la tarea de una solicitud, el texto
  /// de un comentario, el título de la tarea completada (columna opcional
  /// `detail`).
  final String? detail;

  NotificationCategory get category => NotificationCategory.ofType(type);

  bool get isResponse => AppNotificationType.responses.contains(type);

  bool get isAccepted =>
      type == AppNotificationType.requestAccepted ||
      type == AppNotificationType.taskApplicationAccepted;

  bool get isAboutTask =>
      type == AppNotificationType.taskApplication ||
      type == AppNotificationType.taskApplicationAccepted ||
      type == AppNotificationType.taskApplicationRejected ||
      type == AppNotificationType.taskCompleted;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    projectId: projectId,
    title: title,
    message: message,
    createdAt: createdAt,
    type: type,
    requestId: requestId,
    recipientUserId: recipientUserId,
    read: read ?? this.read,
    actorUserId: actorUserId,
    actorName: actorName,
    detail: detail,
  );
}
