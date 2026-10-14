/// Filas de `project_comments`.
abstract class ICommentDataSource {
  Future<List<Map<String, dynamic>>> readForProject(String projectId);

  /// Comentarios escritos por [userId] (para su perfil).
  Future<List<Map<String, dynamic>>> readByAuthor(String userId);

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);
}
