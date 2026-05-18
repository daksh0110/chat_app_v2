import 'package:my_app/modal/screens/message/message_status.dart';

class SendMessageAck {
  final String tempId;
  final String messageId;
  final String chatId;
  final String message;
  final String senderId;
  final int createdAt;
  final List<MessageStatus> messageStatuses;

  SendMessageAck({
    required this.messageId,
    required this.chatId,
    required this.message,
    required this.senderId,
    required this.createdAt,
    required this.messageStatuses,
    this.tempId = "",
  });

  factory SendMessageAck.fromJson(Map<String, dynamic> json) {
    return SendMessageAck(
      tempId: json['temp_id'] ?? "",
      messageId: json['message_id'],
      chatId: json['chat_id'],
      message: json['message'],
      senderId: json['sender_id'],
      createdAt: json['created_at'],
      messageStatuses: (json['message_statuses'] as List)
          .map(
            (status) => MessageStatus(
              messageId: status['message_id'],
              userId: status['user_id'],
              status: status['status'],
              deliveredAt: status['delivered_at'],
              readAt: status['read_at'],
              createdAt: status['created_at'],
              updatedAt: status['updated_at'],
            ),
          )
          .toList(),
    );
  }
}
