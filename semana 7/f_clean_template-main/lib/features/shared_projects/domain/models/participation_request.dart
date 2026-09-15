/// A request a user submitted to participate in a project — either
/// "Postularme a una tarea" or "Unirme al equipo". Both paths end up
/// creating one of these; [role] is the team role they're applying for.
class ParticipationRequest {
  const ParticipationRequest({
    required this.id,
    required this.projectId,
    required this.role,
    required this.message,
  });

  final String id;
  final String projectId;
  final String role;
  final String message;
}
