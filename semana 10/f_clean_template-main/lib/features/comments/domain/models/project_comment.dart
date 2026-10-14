/// A comment left on a project from "Ver proyecto". Persisted in the Roble
/// table `project_comments`.
class ProjectComment {
  const ProjectComment({
    required this.id,
    required this.projectId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.authorUserId,
  });

  final String id;
  final String projectId;
  final String authorName;

  /// Roble user id of whoever was logged in when commenting (may be null).
  final String? authorUserId;
  final String text;
  final DateTime createdAt;
}
