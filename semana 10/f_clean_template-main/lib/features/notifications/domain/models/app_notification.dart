import 'package:f_clean_template/features/notifications/domain/models/notification_category.dart';

/// Kinds of notification the app sends (column `type` of `app_notifications`).
abstract final class AppNotificationType {
  static const String newRequest = 'new_request';

  static const String taskApplication = 'task_application';

  static const String requestAccepted = 'request_accepted';
  static const String requestRejected = 'request_rejected';

  static const String taskApplicationAccepted = 'task_application_accepted';
  static const String taskApplicationRejected = 'task_application_rejected';

  static const String newComment = 'new_comment';
  static const String taskCompleted = 'task_completed';
  static const String newMessage = 'new_message';
  static const String memberJoined = 'member_joined';

  static const Set<String> responses = {
    requestAccepted,
    requestRejected,
    taskApplicationAccepted,
    taskApplicationRejected,
  };

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

  final String? actorUserId;

  final String? actorName;

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
