import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/features/projects/data/datasources/i_project_data_source.dart';

/// Habla con Roble sobre la tabla `projects`. No decide nada.
class RobleProjectDataSource implements IProjectDataSource {
  RobleProjectDataSource(this._client);

  final RobleClient _client;

  static const _table = RobleClient.projects;

  @override
  Future<List<Map<String, dynamic>>> readAll() => _client.db.read(_table);

  @override
  Future<List<Map<String, dynamic>>> readAllPublic() =>
      _client.db.publicRead(_table);

  @override
  Future<Map<String, dynamic>?> readById(String id) =>
      _client.db.getById(_table, id);

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> row) =>
      _client.db.create(_table, row);

  @override
  Future<void> delete(String id) async {
    await _client.db.delete(_table, id);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes) =>
      _client.db.update(_table, id, changes);
}
