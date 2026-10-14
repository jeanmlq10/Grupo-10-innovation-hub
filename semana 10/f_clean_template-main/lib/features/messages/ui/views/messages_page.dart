import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/messages/ui/viewmodels/messages_controller.dart';
import 'package:f_clean_template/features/messages/ui/views/chat_page.dart';
import 'package:f_clean_template/features/messages/ui/widgets/conversation_tile.dart';

/// "Mensajes" (Mi perfil → Mensajes): conversaciones con búsqueda.
/// Una conversación nueva se empieza desde el perfil de otra persona
/// ("Enviar mensaje").
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final MessagesController _controller = Get.find();

  @override
  void initState() {
    super.initState();
    _controller.search.value = '';
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.loadConversations(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Mensajes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: HomeColors.flowSearchFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                onChanged: (value) => _controller.search.value = value,
                decoration: const InputDecoration(
                  hintText: 'Buscar conversaciones...',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = _controller.conversations;
                if (list.isEmpty) {
                  final error = _controller.loadError.value;
                  return Center(
                    child: Text(
                      error.isNotEmpty
                          ? error
                          : 'Todavía no tienes conversaciones.\n'
                                'Escríbele a alguien desde su perfil.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: HomeColors.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _controller.loadConversations,
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) => ConversationTile(
                      conversation: list[index],
                      myUserId: _controller.me ?? '',
                      onTap: () async {
                        await Get.to(
                          () => ChatPage(
                            otherUserId: list[index].otherUserId,
                            otherName: list[index].otherName,
                          ),
                        );
                        _controller.loadConversations();
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
