import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/features/comments/data/datasources/i_comment_data_source.dart';

/// Habla con Roble sobre la tabla `project_comments`. No decide nada.
class RobleCommentDataSource implements ICommentDataSource {
  RobleCommentDataSource(this._client);

  final RobleClient _client;

  static const _table = RobleClient.comments;

  @override
  Future<List<Map<String, dynamic>>> readForProject(String projectId) =>
      _client.db.read(_table, filters: {'projectId': projectId});

  @override
  Future<List<Map<String, dynamic>>> readByAuthor(String userId) =>
      _client.db.read(_table, filters: {'authorUserId': userId});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> row) =>
      _client.db.create(_table, row);
}
