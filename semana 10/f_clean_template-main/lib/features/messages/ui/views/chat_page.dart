import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/features/messages/domain/models/direct_message.dart';
import 'package:f_clean_template/features/messages/ui/viewmodels/messages_controller.dart';
import 'package:f_clean_template/features/messages/ui/widgets/message_bubble.dart';

/// Conversación con otra persona (tabla `direct_messages`).
class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherName,
  });

  final String otherUserId;
  final String otherName;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final MessagesController _controller = Get.find();
  final TextEditingController _text = TextEditingController();
  late Future<List<DirectMessage>> _future;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _future = _controller.thread(widget.otherUserId);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _controller.send(
        toUserId: widget.otherUserId,
        toName: widget.otherName,
        text: text,
      );
      _text.clear();
      setState(() => _future = _controller.thread(widget.otherUserId));
    } catch (error) {
      Get.snackbar(
        'Mensajes',
        errorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = _controller.me ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(widget.otherName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<DirectMessage>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(errorMessage(snapshot.error!)));
                  }
                  final messages = snapshot.data ?? const <DirectMessage>[];
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'Escribe el primer mensaje.',
                        style: TextStyle(color: HomeColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      return MessageBubble(
                        message: message,
                        mine: message.isFrom(me),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        filled: true,
                        fillColor: HomeColors.surfaceGrey,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: HomeColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
