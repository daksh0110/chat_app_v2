import 'package:my_app/modal/screens/message/message_status.dart';

class MessageDeliveredResponse {
  final String chatId;
  final MessageStatus messageStatus;

  MessageDeliveredResponse({required this.chatId, required this.messageStatus});

  factory MessageDeliveredResponse.fromJson(Map<String, dynamic> json) {
    return MessageDeliveredResponse(
      chatId: json['chat_id'],
      messageStatus: MessageStatus(
        messageId: json['message_status']['message_id'],
        userId: json['message_status']['user_id'],
        status: json['message_status']['status'],
        deliveredAt: json['message_status']['delivered_at'],
        readAt: json['message_status']['read_at'],
        createdAt: json['message_status']['created_at'],
        updatedAt: json['message_status']['updated_at'],
      ),
    );
  }
}
