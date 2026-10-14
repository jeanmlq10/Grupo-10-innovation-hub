/// Un mensaje entre dos usuarios (tabla `direct_messages`).
class DirectMessage {
  const DirectMessage({
    required this.id,
    required this.fromUserId,
    required this.fromName,
    required this.toUserId,
    required this.toName,
    required this.text,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String fromUserId;
  final String fromName;
  final String toUserId;
  final String toName;
  final String text;
  final DateTime createdAt;

  /// El destinatario ya lo vio.
  final bool read;

  bool isFrom(String userId) => fromUserId == userId;
}
