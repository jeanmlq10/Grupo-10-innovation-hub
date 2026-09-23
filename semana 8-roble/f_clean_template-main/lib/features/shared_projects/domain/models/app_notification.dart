/// Kinds of notification the projects module sends.
abstract final class AppNotificationType {
  static const String newRequest = 'new_request';
  static const String requestAccepted = 'request_accepted';
  static const String requestRejected = 'request_rejected';
  static const String newComment = 'new_comment';
  static const String memberJoined = 'member_joined';
}

/// A notification of the projects module. Stored by Roble's notifications
/// service (`db.notifications`), addressed to [recipientUserId].
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
}
