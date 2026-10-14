import 'package:f_clean_template/features/messages/domain/models/direct_message.dart';

/// Una conversación de "Mensajes": todos los mensajes con otra persona.
/// Dart puro.
class Conversation {
  const Conversation({
    required this.otherUserId,
    required this.otherName,
    required this.lastMessage,
    required this.unreadCount,
  });

  final String otherUserId;
  final String otherName;
  final DirectMessage lastMessage;

  /// Mensajes que me mandaron y no he leído.
  final int unreadCount;

  /// Agrupa los mensajes de [me] por la otra persona; la más reciente
  /// primero.
  static List<Conversation> group(String me, List<DirectMessage> messages) {
    final byOther = <String, List<DirectMessage>>{};
    for (final message in messages) {
      final other = message.isFrom(me) ? message.toUserId : message.fromUserId;
      if (other.isEmpty || other == me) continue;
      byOther.putIfAbsent(other, () => []).add(message);
    }
    final result = <Conversation>[];
    byOther.forEach((other, list) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final last = list.first;
      result.add(
        Conversation(
          otherUserId: other,
          otherName: last.isFrom(me) ? last.toName : last.fromName,
          lastMessage: last,
          unreadCount: list.where((m) => !m.isFrom(me) && !m.read).length,
        ),
      );
    });
    result.sort(
      (a, b) => b.lastMessage.createdAt.compareTo(a.lastMessage.createdAt),
    );
    return result;
  }
}
