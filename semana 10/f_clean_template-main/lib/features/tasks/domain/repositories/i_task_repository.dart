import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';

/// Tareas especificas de un proyecto (tabla `project_tasks`).
abstract class ITaskRepository {
  /// [publicAccess] = true para el visitante (lectura sin sesion).
  Future<List<ProjectTask>> forProject(
    String projectId, {
    bool publicAccess = false,
  });

  /// Ids de los proyectos que tienen al menos una tarea con cupo
  /// (acceptedCount < requiredCount). Lo usa el filtro de Explorar.
  Future<Set<String>> projectIdsWithOpenTasks({bool publicAccess = false});

  /// Deja las tareas del proyecto igual a [tasks]: crea las nuevas (id vacio),
  /// actualiza las cambiadas y borra las que se quitaron (si nadie fue
  /// aceptado en ellas). Devuelve las tareas como quedaron en Roble.
  Future<List<ProjectTask>> sync(String projectId, List<ProjectTask> tasks);

  /// El dueño marca en qué va la tarea: disponible, en progreso o
  /// completada (columna `status`).
  Future<void> setProgress(ProjectTask task, TaskProgress progress);

  /// Borra todas las tareas de un proyecto (al eliminar un borrador).
  Future<void> deleteForProject(String projectId);

  /// Suma una persona aceptada a la tarea.
  Future<void> addAccepted(ProjectTask task);
}
