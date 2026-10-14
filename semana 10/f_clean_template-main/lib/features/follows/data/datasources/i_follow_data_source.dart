/// Filas de `project_follows`.
abstract class IFollowDataSource {
  Future<List<Map<String, dynamic>>> readForUser(String userId);

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);

  Future<void> delete(String id);
}
