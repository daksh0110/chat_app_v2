class ReplyMessageInfo {
  final String messageId;
  final String senderId;
  final String senderName;
  final String message;

  const ReplyMessageInfo({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'sender_name': senderName,
      'message': message,
    };
  }

  factory ReplyMessageInfo.fromJson(Map<String, dynamic> json) {
    return ReplyMessageInfo(
      messageId: json['message_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderName: json['sender_name']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'ReplyMessageInfo(messageId: $messageId, senderId: $senderId, senderName: $senderName, message: $message)';
  }
}

