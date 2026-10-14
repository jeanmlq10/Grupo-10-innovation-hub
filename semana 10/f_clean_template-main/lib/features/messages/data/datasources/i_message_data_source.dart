/// Filas de `direct_messages`.
abstract class IMessageDataSource {
  Future<List<Map<String, dynamic>>> readSentBy(String userId);

  Future<List<Map<String, dynamic>>> readReceivedBy(String userId);

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes);
}
