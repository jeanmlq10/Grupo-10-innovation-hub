import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/features/tasks/data/datasources/i_task_data_source.dart';

/// Habla con Roble sobre la tabla `project_tasks`. No decide nada.
class RobleTaskDataSource implements ITaskDataSource {
  RobleTaskDataSource(this._client);

  final RobleClient _client;

  static const _table = RobleClient.tasks;

  @override
  Future<List<Map<String, dynamic>>> readForProject(String projectId) =>
      _client.db.read(_table, filters: {'projectId': projectId});

  @override
  Future<List<Map<String, dynamic>>> readForProjectPublic(String projectId) =>
      _client.db.publicRead(_table, filters: {'projectId': projectId});

  @override
  Future<List<Map<String, dynamic>>> readAll() => _client.db.read(_table);

  @override
  Future<List<Map<String, dynamic>>> readAllPublic() =>
      _client.db.publicRead(_table);

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> row) =>
      _client.db.create(_table, row);

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes) =>
      _client.db.update(_table, id, changes);

  @override
  Future<void> delete(String id) async {
    await _client.db.delete(_table, id);
  }
}
