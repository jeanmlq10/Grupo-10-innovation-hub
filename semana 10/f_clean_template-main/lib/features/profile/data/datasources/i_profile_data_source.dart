/// Filas de `user_profiles`.
abstract class IProfileDataSource {
  Future<List<Map<String, dynamic>>> readForUser(String userId);

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes);

  Future<void> delete(String id);
}
