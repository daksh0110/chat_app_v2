class MessageModel {
  final String id;
  final String text;
  final bool isMe;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.text,
    required this.isMe,
    required this.createdAt,
  });
}
