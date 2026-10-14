import 'package:f_clean_template/core/utils/deadline.dart';

/// En qué va el trabajo de una tarea (columna `status` de `project_tasks`).
/// Lo define el dueño del proyecto (requerimiento 3.1).
enum TaskProgress { available, inProgress, completed }

/// Lo que se le muestra a la gente en la tarjeta de la tarea.
enum TaskDisplayStatus { available, inProgress, completed, closed }

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
    this.deadline,
    this.progress = TaskProgress.available,
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

  /// "Disponible hasta": último día para postularse (columna `deadline`).
  final DateTime? deadline;

  /// Estado del trabajo que marcó el dueño (columna `status`).
  final TaskProgress progress;

  bool get hasSpots => numberAccepted < numberNeeded;

  /// Se puede postular: está disponible, tiene cupo y no venció la fecha.
  bool canApplyAt([DateTime? now]) =>
      progress == TaskProgress.available &&
      hasSpots &&
      isBeforeDeadline(deadline, now);

  /// Estado para mostrar: Completada > En progreso (marcada o sin cupo) >
  /// Cerrada (venció la fecha) > Disponible.
  TaskDisplayStatus displayStatusAt([DateTime? now]) {
    if (progress == TaskProgress.completed) return TaskDisplayStatus.completed;
    if (progress == TaskProgress.inProgress || !hasSpots) {
      return TaskDisplayStatus.inProgress;
    }
    if (!isBeforeDeadline(deadline, now)) return TaskDisplayStatus.closed;
    return TaskDisplayStatus.available;
  }

  ProjectTask copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    int? numberNeeded,
    int? numberAccepted,
    String? status,
    DateTime? deadline,
    TaskProgress? progress,
  }) => ProjectTask(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    description: description ?? this.description,
    numberNeeded: numberNeeded ?? this.numberNeeded,
    numberAccepted: numberAccepted ?? this.numberAccepted,
    status: status ?? this.status,
    createdAt: createdAt,
    deadline: deadline ?? this.deadline,
    progress: progress ?? this.progress,
  );
}
