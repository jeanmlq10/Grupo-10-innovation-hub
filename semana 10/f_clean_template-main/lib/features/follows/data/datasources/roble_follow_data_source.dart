import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/features/follows/data/datasources/i_follow_data_source.dart';

/// Habla con Roble sobre la tabla `project_follows`. No decide nada.
class RobleFollowDataSource implements IFollowDataSource {
  RobleFollowDataSource(this._client);

  final RobleClient _client;

  static const _table = RobleClient.follows;

  @override
  Future<List<Map<String, dynamic>>> readForUser(String userId) =>
      _client.db.read(_table, filters: {'userId': userId});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> row) =>
      _client.db.create(_table, row);

  @override
  Future<void> delete(String id) async {
    await _client.db.delete(_table, id);
  }
}
