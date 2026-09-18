/// Where a [ParticipationRequest] currently stands.
enum RequestStatus { pending, accepted, rejected }

/// A request a user submitted to participate in a project — either
/// "Postularme a una tarea" or "Unirme al equipo". Both paths end up
/// creating one of these; [role] is the team role they're applying for.
/// [applicantUserId] is the Roble user id of whoever is logged in when
/// the request is created.
class ParticipationRequest {
  const ParticipationRequest({
    required this.id,
    required this.projectId,
    required this.role,
    required this.message,
    this.applicantName = 'Usuario interesado',
    this.applicantUserId,
    this.applicantEmail,
    this.status = RequestStatus.pending,
  });

  final String id;
  final String projectId;
  final String role;
  final String message;
  final String applicantName;
  final String? applicantUserId;
  final String? applicantEmail;
  final RequestStatus status;

  ParticipationRequest copyWith({RequestStatus? status}) =>
      ParticipationRequest(
        id: id,
        projectId: projectId,
        role: role,
        message: message,
        applicantName: applicantName,
        applicantUserId: applicantUserId,
        applicantEmail: applicantEmail,
        status: status ?? this.status,
      );
}
