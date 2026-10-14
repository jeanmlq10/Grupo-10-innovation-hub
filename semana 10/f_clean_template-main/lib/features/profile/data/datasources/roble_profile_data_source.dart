import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/features/profile/data/datasources/i_profile_data_source.dart';

/// Habla con Roble sobre la tabla `user_profiles`. No decide nada.
class RobleProfileDataSource implements IProfileDataSource {
  RobleProfileDataSource(this._client);

  final RobleClient _client;

  static const _table = RobleClient.profiles;

  @override
  Future<List<Map<String, dynamic>>> readForUser(String userId) =>
      _client.db.read(_table, filters: {'userId': userId});

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
