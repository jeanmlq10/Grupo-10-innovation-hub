import 'package:f_clean_template/core/roble/roble_guard.dart';
import 'package:f_clean_template/core/roble/roble_rows.dart';
import 'package:f_clean_template/features/messages/data/datasources/i_message_data_source.dart';
import 'package:f_clean_template/features/messages/domain/message_failure.dart';
import 'package:f_clean_template/features/messages/domain/models/direct_message.dart';
import 'package:f_clean_template/features/messages/domain/repositories/i_message_repository.dart';

/// Mensajes: convierte filas y traduce errores. Un mensaje enviado solo
/// cuenta si lo escribió de verdad quien dice enviarlo (`_owner`).
class MessageRepository implements IMessageRepository {
  MessageRepository(this._source);

  final IMessageDataSource _source;

  Future<T> _guard<T>(Future<T> Function() action) =>
      robleGuard(action, MessageFailure.new);

  @override
  Future<List<DirectMessage>> allOf(String userId) async {
    final results = await Future.wait([
      _guard(() => _source.readSentBy(userId)),
      _guard(() => _source.readReceivedBy(userId)),
    ]);
    final seen = <String>{};
    return [
      for (final row in [...results[0], ...results[1]])
        if (seen.add(RobleRows.str(row['_id'])) && _isGenuine(row))
          _toMessage(row),
    ];
  }

  @override
  Future<List<DirectMessage>> thread(String me, String other) async {
    final all = await allOf(me);
    return all
        .where(
          (m) =>
              (m.fromUserId == me && m.toUserId == other) ||
              (m.fromUserId == other && m.toUserId == me),
        )
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<DirectMessage> send(DirectMessage message) async {
    final row = await _guard(
      () => _source.create({
        'fromUserId': message.fromUserId,
        'fromName': message.fromName,
        'toUserId': message.toUserId,
        'toName': message.toName,
        'text': message.text,
        'read': false,
        'createdAt': RobleRows.nowIso(),
      }),
    );
    return _toMessage(row);
  }

  @override
  Future<void> markThreadRead(String me, String other) async {
    final unread = (await _guard(() => _source.readReceivedBy(me))).where(
      (row) =>
          RobleRows.str(row['fromUserId']) == other &&
          !RobleRows.boolean(row['read']),
    );
    for (final row in unread) {
      await _guard(
        () => _source.update(RobleRows.str(row['_id']), {'read': true}),
      );
    }
  }

  bool _isGenuine(Map<String, dynamic> row) =>
      RobleRows.author(row, 'fromUserId') == RobleRows.str(row['fromUserId']);

  DirectMessage _toMessage(Map<String, dynamic> row) => DirectMessage(
    id: RobleRows.str(row['_id']),
    fromUserId: RobleRows.str(row['fromUserId']),
    fromName: RobleRows.str(row['fromName'], 'Usuario'),
    toUserId: RobleRows.str(row['toUserId']),
    toName: RobleRows.str(row['toName'], 'Usuario'),
    text: RobleRows.str(row['text']),
    createdAt: RobleRows.date(row['createdAt']) ?? DateTime.now(),
    read: RobleRows.boolean(row['read']),
  );
}
