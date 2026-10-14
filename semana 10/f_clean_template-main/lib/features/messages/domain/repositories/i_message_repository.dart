import 'package:f_clean_template/features/messages/domain/models/direct_message.dart';

/// Mensajes directos (tabla `direct_messages`).
abstract class IMessageRepository {
  /// Todos los mensajes que envió o recibió [userId].
  Future<List<DirectMessage>> allOf(String userId);

  /// La conversación entre [me] y [other], del más viejo al más nuevo.
  Future<List<DirectMessage>> thread(String me, String other);

  Future<DirectMessage> send(DirectMessage message);

  /// Marca como leídos los mensajes que [me] recibió de [other].
  Future<void> markThreadRead(String me, String other);
}
