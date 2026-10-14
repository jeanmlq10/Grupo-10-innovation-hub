/// Filas de `project_members`.
abstract class IMemberDataSource {
  Future<List<Map<String, dynamic>>> readForProject(String projectId);

  /// Filas donde [userId] es el miembro (para su perfil).
  Future<List<Map<String, dynamic>>> readForUser(String userId);

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);
}
