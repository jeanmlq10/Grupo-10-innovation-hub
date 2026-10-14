import 'package:f_clean_template/features/messages/domain/models/direct_message.dart';

/// Mensajes directos (tabla `direct_messages`).
abstract class IMessageRepository {
  Future<List<DirectMessage>> allOf(String userId);

  Future<List<DirectMessage>> thread(String me, String other);

  Future<DirectMessage> send(DirectMessage message);

  Future<void> markThreadRead(String me, String other);
}
