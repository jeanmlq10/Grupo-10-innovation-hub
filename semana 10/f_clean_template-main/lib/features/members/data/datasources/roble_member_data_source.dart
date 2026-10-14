import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/features/members/data/datasources/i_member_data_source.dart';

/// Habla con Roble sobre la tabla `project_members`. No decide nada.
class RobleMemberDataSource implements IMemberDataSource {
  RobleMemberDataSource(this._client);

  final RobleClient _client;

  static const _table = RobleClient.members;

  @override
  Future<List<Map<String, dynamic>>> readForProject(String projectId) =>
      _client.db.read(_table, filters: {'projectId': projectId});

  @override
  Future<List<Map<String, dynamic>>> readForUser(String userId) =>
      _client.db.read(_table, filters: {'userId': userId});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> row) =>
      _client.db.create(_table, row);
}
