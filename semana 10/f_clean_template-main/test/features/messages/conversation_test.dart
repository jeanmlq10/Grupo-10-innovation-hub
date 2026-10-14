import 'package:flutter_test/flutter_test.dart';

import 'package:f_clean_template/features/messages/domain/models/conversation.dart';
import 'package:f_clean_template/features/messages/domain/models/direct_message.dart';

DirectMessage _m(String from, String to, int minute, {bool read = false}) =>
    DirectMessage(
      id: '$from$to$minute',
      fromUserId: from,
      fromName: from.toUpperCase(),
      toUserId: to,
      toName: to.toUpperCase(),
      text: 'hola $minute',
      createdAt: DateTime(2026, 10, 14, 10, minute),
      read: read,
    );

void main() {
  test('agrupa por la otra persona y cuenta no leídos', () {
    final list = Conversation.group('me', [
      _m('ana', 'me', 1),
      _m('me', 'ana', 2),
      _m('ana', 'me', 3),
      _m('juan', 'me', 0, read: true),
    ]);
    expect(list.map((c) => c.otherUserId), ['ana', 'juan']);
    expect(list.first.otherName, 'ANA');
    expect(list.first.unreadCount, 2);
    expect(list.last.unreadCount, 0);
  });
}
