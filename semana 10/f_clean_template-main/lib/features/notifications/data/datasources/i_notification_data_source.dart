/// Filas de `app_notifications`.
abstract class INotificationDataSource {
  Future<List<Map<String, dynamic>>> readForRecipient(String userId);

  Future<Map<String, dynamic>> create(Map<String, dynamic> row);

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes);
}
