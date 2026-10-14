/// Lo que la feature necesita que alguien sepa hablar sobre proyectos.
///
/// En filas (lo que viaja por la API), no en entidades: la conversion la
/// hace el repositorio.
abstract class IProjectDataSource {
  Future<List<Map<String, dynamic>>> readAll();

  /// Igual que [readAll] pero SIN sesión (modo visitante). Requiere que la
  /// tabla esté marcada como pública en la consola de Roble.
  Future<List<Map<String, dynamic>>> readAllPublic();

  Future<Map<String, dynamic>?> readById(String id);

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes);

  Future<void> delete(String id);
}
