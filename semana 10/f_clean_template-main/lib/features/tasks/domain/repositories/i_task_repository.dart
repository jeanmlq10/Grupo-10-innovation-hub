import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';

/// Tareas especificas de un proyecto (tabla `project_tasks`).
abstract class ITaskRepository {
  Future<List<ProjectTask>> forProject(
    String projectId, {
    bool publicAccess = false,
  });

  Future<Set<String>> projectIdsWithOpenTasks({bool publicAccess = false});

  Future<List<ProjectTask>> sync(String projectId, List<ProjectTask> tasks);

  Future<void> setProgress(ProjectTask task, TaskProgress progress);

  Future<void> deleteForProject(String projectId);

  Future<void> addAccepted(ProjectTask task);
}
