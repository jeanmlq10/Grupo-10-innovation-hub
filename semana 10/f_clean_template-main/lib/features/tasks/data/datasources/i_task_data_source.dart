/// Filas de `project_tasks`.
abstract class ITaskDataSource {
  Future<List<Map<String, dynamic>>> readForProject(String projectId);

  Future<List<Map<String, dynamic>>> readForProjectPublic(String projectId);

  Future<List<Map<String, dynamic>>> readAll();

  Future<List<Map<String, dynamic>>> readAllPublic();

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes);

  Future<void> delete(String id);
}
