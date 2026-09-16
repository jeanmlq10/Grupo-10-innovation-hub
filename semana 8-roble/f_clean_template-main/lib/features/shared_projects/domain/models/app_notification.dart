/// A local notification. This stage only produces one kind — "someone
/// wants to join your project" — but the shape is generic enough for
/// more kinds later.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.requestId,
    required this.projectId,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String requestId;
  final String projectId;
  final String title;
  final String message;
  final DateTime createdAt;
}
