/// A long-term role the project needs in its team ("Diseñador/a",
/// "Líder de proyecto"...), with how many people are needed and how many
/// were already accepted. Persisted in the Roble table `project_roles`.
class ProjectTeamRole {
  const ProjectTeamRole({
    required this.id,
    required this.projectId,
    required this.role,
    this.numberNeeded = 1,
    this.numberAccepted = 0,
    this.status = 'open',
  });

  /// Roble `_id`.
  final String id;
  final String projectId;
  final String role;
  final int numberNeeded;
  final int numberAccepted;

  /// `open` while there are free spots, `closed` once filled.
  final String status;

  bool get hasSpots => numberAccepted < numberNeeded;
}
