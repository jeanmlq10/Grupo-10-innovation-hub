import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/time_ago.dart';
import 'package:f_clean_template/features/messages/domain/models/conversation.dart';

/// Una conversación en "Mensajes": avatar, nombre, último mensaje, cuándo
/// y el punto si hay mensajes sin leer.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.myUserId,
    required this.onTap,
  });

  final Conversation conversation;
  final String myUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final last = conversation.lastMessage;
    final preview = last.isFrom(myUserId) ? 'Tú: ${last.text}' : last.text;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: HomeColors.navSelectedBackground,
              child: Text(
                conversation.otherName.isEmpty
                    ? '?'
                    : conversation.otherName[0].toUpperCase(),
                style: const TextStyle(
                  color: HomeColors.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.otherName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeAgo(last.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: HomeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                if (conversation.unreadCount > 0)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: HomeColors.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
