import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/features/notifications/data/datasources/i_notification_data_source.dart';

/// Habla con Roble sobre la tabla `app_notifications`. No decide nada.
class RobleNotificationDataSource implements INotificationDataSource {
  RobleNotificationDataSource(this._client);

  final RobleClient _client;

  static const _table = RobleClient.notifications;

  @override
  Future<List<Map<String, dynamic>>> readForRecipient(String userId) =>
      _client.db.read(_table, filters: {'recipientUserId': userId});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> row) =>
      _client.db.create(_table, row);

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes) =>
      _client.db.update(_table, id, changes);
}
