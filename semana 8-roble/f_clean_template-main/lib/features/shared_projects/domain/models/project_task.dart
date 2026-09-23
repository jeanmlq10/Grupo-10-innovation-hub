/// A concrete task a project needs help with ("Diseñar la interfaz",
/// "Hacer pruebas"...). Someone can apply to one specific task. Different
/// from a [ProjectTeamRole], which is a long-term place in the team.
///
/// Persisted in the Roble table `project_tasks`.
class ProjectTask {
  const ProjectTask({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.numberNeeded = 1,
    this.numberAccepted = 0,
    this.status = 'open',
    this.createdAt,
  });

  /// Roble `_id`. Empty while the task only exists in the wizard.
  final String id;
  final String projectId;
  final String title;
  final String description;
  final int numberNeeded;
  final int numberAccepted;

  /// `open` while there are free spots, `closed` once filled.
  final String status;
  final DateTime? createdAt;

  bool get hasSpots => numberAccepted < numberNeeded;

  ProjectTask copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    int? numberNeeded,
    int? numberAccepted,
    String? status,
  }) => ProjectTask(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    description: description ?? this.description,
    numberNeeded: numberNeeded ?? this.numberNeeded,
    numberAccepted: numberAccepted ?? this.numberAccepted,
    status: status ?? this.status,
    createdAt: createdAt,
  );
}
