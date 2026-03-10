enum MessageStatus { sending, sent, delivered, read, failed }

class MessageModel {
  final String id;
  final String text;
  final bool isMe;
  final DateTime createdAt;
  // final MessageStatus status;

  MessageModel({
    required this.id,
    required this.text,
    required this.isMe,
    required this.createdAt,
    // this.status = MessageStatus.sending,
  });
}
