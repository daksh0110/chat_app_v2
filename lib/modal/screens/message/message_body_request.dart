class MessageBodyRequest {
  final String? chatId;
  final String? tempId;
  final String? message;
  final String? senderId;
  final bool isRead;
  final int createdAt;
  final int? serverCreatedAt;
  final String? messageId;

  MessageBodyRequest({
    this.chatId,
    this.tempId,
    this.message,
    this.senderId,
    this.isRead = false,
    this.messageId,
    int? createdAt,
    this.serverCreatedAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;
}
