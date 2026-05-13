class MessageStatus {
  final String messageId;
  final String userId;
  final String status;
  final int? deliveredAt;
  final int? readAt;
  final int createdAt;
  final int updatedAt;

  MessageStatus({
    required this.messageId,
    required this.userId,
    required this.status,
    this.deliveredAt,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
