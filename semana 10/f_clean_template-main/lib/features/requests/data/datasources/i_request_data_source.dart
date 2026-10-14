/// Filas de `project_requests` y `request_decisions`.
abstract class IRequestDataSource {
  Future<List<Map<String, dynamic>>> readRequests({String? projectId});

  /// Solicitudes enviadas por [userId] (para su perfil).
  Future<List<Map<String, dynamic>>> readByApplicant(String userId);

  Future<Map<String, dynamic>> createRequest(Map<String, dynamic> row);

  Future<List<Map<String, dynamic>>> readDecisions();

  Future<Map<String, dynamic>> createDecision(Map<String, dynamic> row);
}
