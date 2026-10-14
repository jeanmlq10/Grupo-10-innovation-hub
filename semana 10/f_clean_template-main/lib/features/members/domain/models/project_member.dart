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

  final String userId;
  final String name;
  final String? email;

  final String role;
  final MemberSourceType sourceType;

  final String? sourceId;
  final String? requestId;
  final DateTime? joinedAt;

  final String? recordedBy;
}
