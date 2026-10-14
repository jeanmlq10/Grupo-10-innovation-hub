/// Filas de `project_members`.
abstract class IMemberDataSource {
  Future<List<Map<String, dynamic>>> readForProject(String projectId);

  Future<List<Map<String, dynamic>>> readForUser(String userId);

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);
}
