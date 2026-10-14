/// Filas de `project_tasks`.
abstract class ITaskDataSource {
  Future<List<Map<String, dynamic>>> readForProject(String projectId);

  /// Sin sesion (modo visitante). La tabla debe ser publica en Roble.
  Future<List<Map<String, dynamic>>> readForProjectPublic(String projectId);

  /// Todas las tareas (para el filtro "Disponibilidad de tareas").
  Future<List<Map<String, dynamic>>> readAll();

  /// Todas las tareas, sin sesion (modo visitante).
  Future<List<Map<String, dynamic>>> readAllPublic();

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes);

  Future<void> delete(String id);
}
