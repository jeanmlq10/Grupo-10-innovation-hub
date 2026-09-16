/// Where a [ParticipationRequest] currently stands.
enum RequestStatus { pending, accepted, rejected }

/// A request a user submitted to participate in a project — either
/// "Postularme a una tarea" or "Unirme al equipo". Both paths end up
/// creating one of these; [role] is the team role they're applying for.
///
/// There's no login/account system in this app yet, so [applicantName]
/// is a generic placeholder rather than a real identity — the same
/// device is used to both create and apply to projects while testing
/// this flow.
class ParticipationRequest {
  const ParticipationRequest({
    required this.id,
    required this.projectId,
    required this.role,
    required this.message,
    this.applicantName = 'Usuario interesado',
    this.status = RequestStatus.pending,
  });

  final String id;
  final String projectId;
  final String role;
  final String message;
  final String applicantName;
  final RequestStatus status;

  ParticipationRequest copyWith({RequestStatus? status}) =>
      ParticipationRequest(
        id: id,
        projectId: projectId,
        role: role,
        message: message,
        applicantName: applicantName,
        status: status ?? this.status,
      );
}
