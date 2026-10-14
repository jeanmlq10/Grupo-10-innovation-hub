/// Lo que la feature necesita que alguien sepa hablar sobre proyectos.
abstract class IProjectDataSource {
  Future<List<Map<String, dynamic>>> readAll();

  Future<List<Map<String, dynamic>>> readAllPublic();

  Future<Map<String, dynamic>?> readById(String id);

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes);

  Future<void> delete(String id);
}
