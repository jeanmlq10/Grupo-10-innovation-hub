/// Que [userId] sigue el proyecto [projectId] (tabla `project_follows`).
class ProjectFollow {
  const ProjectFollow({
    required this.projectId,
    required this.userId,
    this.createdAt,
  });

  final String projectId;
  final String userId;
  final DateTime? createdAt;
}
