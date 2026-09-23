/// Where a [ParticipationRequest] currently stands.
enum RequestStatus { pending, accepted, rejected }

/// "Postularme a una tarea" ([task]) or "Unirme al equipo" ([team]).
enum RequestType { task, team }

/// A request a user submitted to participate in a project. Persisted in the
/// Roble table `participation_requests`; its status comes from the owner's
/// decision (table `request_decisions`), because the request row belongs to
/// the applicant and only the owner may decide on it.
class ParticipationRequest {
  const ParticipationRequest({
    required this.id,
    required this.projectId,
    required this.role,
    required this.message,
    this.type = RequestType.team,
    this.taskId,
    this.teamRoleId,
    this.projectOwnerId,
    this.projectName,
    this.applicantName = 'Usuario interesado',
    this.applicantUserId,
    this.applicantEmail,
    this.status = RequestStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String projectId;

  /// Label shown in the UI: the task title or the team role name.
  final String role;
  final String message;
  final RequestType type;

  /// `_id` of the task (type task) or of the team role row (type team).
  final String? taskId;
  final String? teamRoleId;

  /// Roble userId of the project creator (who can decide on it).
  final String? projectOwnerId;
  final String? projectName;
  final String applicantName;
  final String? applicantUserId;
  final String? applicantEmail;
  final RequestStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ParticipationRequest copyWith({
    RequestStatus? status,
    DateTime? updatedAt,
    String? projectName,
  }) => ParticipationRequest(
    id: id,
    projectId: projectId,
    role: role,
    message: message,
    type: type,
    taskId: taskId,
    teamRoleId: teamRoleId,
    projectOwnerId: projectOwnerId,
    projectName: projectName ?? this.projectName,
    applicantName: applicantName,
    applicantUserId: applicantUserId,
    applicantEmail: applicantEmail,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
