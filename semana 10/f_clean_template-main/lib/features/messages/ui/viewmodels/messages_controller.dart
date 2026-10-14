import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/messages/domain/models/conversation.dart';
import 'package:f_clean_template/features/messages/domain/models/direct_message.dart';
import 'package:f_clean_template/features/messages/domain/repositories/i_message_repository.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';

/// ViewModel de "Mensajes" (lista de conversaciones) y del chat.
///
/// Reglas: no se escribe a uno mismo, y se respeta "Quién puede
/// contactarte" del perfil de la otra persona. Cada mensaje nuevo avisa al
/// destinatario ("Nuevos mensajes").
class MessagesController extends GetxController with UiLoggy {
  MessagesController({
    required this.messages,
    required this.profiles,
    required this.notifications,
    required this.session,
  });

  final IMessageRepository messages;
  final IProfileRepository profiles;
  final INotificationRepository notifications;
  final AuthenticationController session;

  final RxList<Conversation> _conversations = <Conversation>[].obs;
  final RxBool isLoading = false.obs;
  final RxString search = ''.obs;
  final RxString loadError = ''.obs;

  String? get me => session.loggedUser?.userId;

  /// Conversaciones filtradas por "Buscar conversaciones...".
  List<Conversation> get conversations {
    final query = search.value.trim().toLowerCase();
    if (query.isEmpty) return _conversations;
    return _conversations
        .where(
          (c) =>
              c.otherName.toLowerCase().contains(query) ||
              c.lastMessage.text.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadConversations() async {
    final userId = me;
    if (userId == null) return;
    isLoading.value = true;
    loadError.value = '';
    try {
      _conversations.assignAll(
        Conversation.group(userId, await messages.allOf(userId)),
      );
    } catch (error) {
      loggy.error('MessagesController: could not load: $error');
      loadError.value = errorMessage(
        error,
        fallback: 'No se pudieron cargar tus mensajes.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Mensajes con [otherUserId]; los recibidos quedan como leídos.
  Future<List<DirectMessage>> thread(String otherUserId) async {
    final userId = me;
    if (userId == null) return const [];
    final list = await messages.thread(userId, otherUserId);
    try {
      await messages.markThreadRead(userId, otherUserId);
    } catch (_) {
      // Si no se pudo marcar como leído, el chat se muestra igual.
    }
    return list;
  }

  /// ¿Se le puede escribir a [otherUserId]? (su privacidad)
  Future<bool> canWriteTo(String otherUserId) async {
    if (otherUserId.isEmpty || otherUserId == me) return false;
    final profile = await profiles
        .byUserId(otherUserId)
        .catchError((Object _) => null);
    return profile?.acceptsMessages ?? true;
  }

  Future<void> send({
    required String toUserId,
    required String toName,
    required String text,
  }) async {
    final user = session.loggedUser;
    if (user == null) throw StateError('Debes iniciar sesión para escribir.');
    final clean = text.trim();
    if (clean.isEmpty) return;
    if (toUserId == user.userId) {
      throw StateError('No puedes enviarte mensajes a ti mismo.');
    }
    if (!await canWriteTo(toUserId)) {
      throw StateError('Esta persona no recibe mensajes.');
    }
    final myName = user.name.isEmpty ? user.email : user.name;
    await messages.send(
      DirectMessage(
        id: '',
        fromUserId: user.userId,
        fromName: myName,
        toUserId: toUserId,
        toName: toName,
        text: clean,
        createdAt: DateTime.now(),
      ),
    );
    try {
      await notifications.send(
        recipientUserId: toUserId,
        type: AppNotificationType.newMessage,
        title: 'Nuevo mensaje',
        message: '$myName te envió un mensaje.',
        projectId: '',
        actorUserId: user.userId,
        actorName: myName,
        detail: clean,
      );
    } catch (_) {
      // El mensaje ya quedó guardado; el aviso es secundario.
    }
  }
}
