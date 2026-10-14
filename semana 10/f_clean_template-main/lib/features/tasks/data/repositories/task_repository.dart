import 'package:roble/roble.dart' show RobleApiNotFoundException;

import 'package:f_clean_template/core/roble/roble_guard.dart';
import 'package:f_clean_template/core/roble/roble_optional_columns.dart';
import 'package:f_clean_template/core/roble/roble_rows.dart';
import 'package:f_clean_template/features/tasks/data/datasources/i_task_data_source.dart';
import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';
import 'package:f_clean_template/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:f_clean_template/features/tasks/domain/task_failure.dart';

/// Tareas especificas: sincroniza, convierte filas y traduce errores.
class TaskRepository implements ITaskRepository {
  TaskRepository(this._source);

  final ITaskDataSource _source;

  static const _optionalColumns = {'deadline', 'status'};

  Future<T> _guard<T>(Future<T> Function() action) =>
      robleGuard(action, TaskFailure.new, notFound: 'Esa tarea ya no existe.');

  @override
  Future<List<ProjectTask>> forProject(
    String projectId, {
    bool publicAccess = false,
  }) async {
    final rows = await _guard(
      () => publicAccess
          ? _source.readForProjectPublic(projectId)
          : _source.readForProject(projectId),
    );
    return rows.map(_toTask).toList();
  }

  @override
  Future<Set<String>> projectIdsWithOpenTasks({
    bool publicAccess = false,
  }) async {
    final rows = await _guard(
      publicAccess ? _source.readAllPublic : _source.readAll,
    );
    return rows
        .map(_toTask)
        .where((task) => task.canApplyAt())
        .map((task) => task.projectId)
        .toSet();
  }

  @override
  Future<List<ProjectTask>> sync(
    String projectId,
    List<ProjectTask> tasks,
  ) async {
    final existing = {for (final t in await forProject(projectId)) t.id: t};

    for (final task in tasks) {
      final title = task.title.trim();
      if (title.isEmpty) continue;
      final current = task.id.isEmpty ? null : existing.remove(task.id);
      if (current == null) {
        await _guard(
          () => RobleOptionalColumns.write(
            {
              'projectId': projectId,
              'title': title,
              'description': task.description,
              'requiredCount': task.numberNeeded,
              'acceptedCount': 0,
              'deadline': RobleRows.dayIso(task.deadline),
              'status': _progressToRow(task.progress),
            },
            _source.create,
            optional: _optionalColumns,
          ),
        );
      } else if (current.title != title ||
          current.description != task.description ||
          current.numberNeeded != task.numberNeeded ||
          current.deadline != task.deadline) {
        await _guard(
          () => RobleOptionalColumns.write(
            {
              'title': title,
              'description': task.description,
              'requiredCount': task.numberNeeded,
              'deadline': RobleRows.dayIso(task.deadline),
            },
            (row) => _source.update(current.id, row),
            optional: _optionalColumns,
          ),
        );
      }
    }

    for (final leftover in existing.values) {
      if (leftover.numberAccepted == 0) {
        await _guard(() async {
          try {
            await _source.delete(leftover.id);
          } on RobleApiNotFoundException {
            return;
          }
        });
      } else {
        await _guard(
          () => _source.update(leftover.id, {
            'requiredCount': leftover.numberAccepted,
          }),
        );
      }
    }
    return forProject(projectId);
  }

  @override
  Future<void> deleteForProject(String projectId) async {
    for (final task in await forProject(projectId)) {
      await _guard(() async {
        try {
          await _source.delete(task.id);
        } on RobleApiNotFoundException {
          return;
        }
      });
    }
  }

  @override
  Future<void> addAccepted(ProjectTask task) async {
    await _guard(
      () => _source.update(task.id, {'acceptedCount': task.numberAccepted + 1}),
    );
  }

  @override
  Future<void> setProgress(ProjectTask task, TaskProgress progress) async {
    await _guard(
      () => _source.update(task.id, {'status': _progressToRow(progress)}),
    );
  }

  static String _progressToRow(TaskProgress progress) => switch (progress) {
    TaskProgress.available => 'available',
    TaskProgress.inProgress => 'in_progress',
    TaskProgress.completed => 'completed',
  };

  static TaskProgress _progressFromRow(Object? value) =>
      switch (RobleRows.str(value)) {
        'in_progress' => TaskProgress.inProgress,
        'completed' => TaskProgress.completed,
        _ => TaskProgress.available,
      };

  ProjectTask _toTask(Map<String, dynamic> row) {
    final needed = RobleRows.integer(row['requiredCount']);
    final accepted = RobleRows.integer(row['acceptedCount']);
    return ProjectTask(
      id: RobleRows.str(row['_id']),
      projectId: RobleRows.str(row['projectId']),
      title: RobleRows.str(row['title']),
      description: RobleRows.str(row['description']),
      numberNeeded: needed,
      numberAccepted: accepted,
      status: accepted >= needed ? 'closed' : 'open',
      deadline: RobleRows.day(row['deadline']),
      progress: _progressFromRow(row['status']),
    );
  }
}
