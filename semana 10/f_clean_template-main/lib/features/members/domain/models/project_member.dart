/// Whether someone joined through a specific task or as a team member.
enum MemberSourceType { task, team }

/// A real member of a project: created when the owner accepts a
/// participation request. Persisted in the Roble table `project_members`.
class ProjectMember {
  const ProjectMember({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.name,
    required this.role,
    required this.sourceType,
    this.email,
    this.sourceId,
    this.requestId,
    this.joinedAt,
    this.recordedBy,
  });

  final String id;
  final String projectId;

  /// Roble userId of the member.
  final String userId;
  final String name;
  final String? email;

  /// Task title or team role the member joined for.
  final String role;
  final MemberSourceType sourceType;

  /// `_id` of the task or team role row, when known.
  final String? sourceId;
  final String? requestId;
  final DateTime? joinedAt;

  /// userId de quien escribió la fila (`_owner`). Una participación es
  /// válida solo si la registró el creador del proyecto.
  final String? recordedBy;
}
