import 'package:f_clean_template/core/utils/deadline.dart';

/// En qué va el trabajo de una tarea (columna `status` de `project_tasks`).
/// Lo define el dueño del proyecto (requerimiento 3.1).
enum TaskProgress { available, inProgress, completed }

/// Lo que se le muestra a la gente en la tarjeta de la tarea.
enum TaskDisplayStatus { available, inProgress, completed, closed }

/// A concrete task a project needs help with ("Diseñar la interfaz",
/// "Hacer pruebas"...). Someone can apply to one specific task. Different
/// from a [ProjectTeamRole], which is a long-term place in the team.
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

  final String id;
  final String projectId;
  final String title;
  final String description;
  final int numberNeeded;
  final int numberAccepted;

  final String status;
  final DateTime? createdAt;

  final DateTime? deadline;

  final TaskProgress progress;

  bool get hasSpots => numberAccepted < numberNeeded;

  bool canApplyAt([DateTime? now]) =>
      progress == TaskProgress.available &&
      hasSpots &&
      isBeforeDeadline(deadline, now);

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
