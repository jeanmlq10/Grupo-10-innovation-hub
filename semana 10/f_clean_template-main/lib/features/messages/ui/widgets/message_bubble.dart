import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/time_ago.dart';
import 'package:f_clean_template/features/messages/domain/models/direct_message.dart';

/// Burbuja de chat: morada a la derecha si es mía, gris a la izquierda si no.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.mine});

  final DirectMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: mine ? HomeColors.primaryPurple : HomeColors.surfaceGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: mine ? Colors.white : HomeColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeAgo(message.createdAt),
              style: TextStyle(
                fontSize: 10.5,
                color: mine ? Colors.white70 : HomeColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
