import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/features/messages/data/datasources/i_message_data_source.dart';

/// Habla con Roble sobre la tabla `direct_messages`. No decide nada.
class RobleMessageDataSource implements IMessageDataSource {
  RobleMessageDataSource(this._client);

  final RobleClient _client;

  static const _table = RobleClient.messages;

  @override
  Future<List<Map<String, dynamic>>> readSentBy(String userId) =>
      _client.db.read(_table, filters: {'fromUserId': userId});

  @override
  Future<List<Map<String, dynamic>>> readReceivedBy(String userId) =>
      _client.db.read(_table, filters: {'toUserId': userId});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> row) =>
      _client.db.create(_table, row);

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> changes) =>
      _client.db.update(_table, id, changes);
}
