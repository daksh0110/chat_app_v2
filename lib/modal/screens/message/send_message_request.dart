import 'package:image_picker/image_picker.dart';
import 'package:my_app/modal/screens/message/reply_message_info.dart';

class SendMessageRequest {
  final String message;
  final String receiverId;
  final String receiverName;
  final List<XFile> attachments;
  final String? chatId;
  final String? type;
  final void Function(String realChatId)? onChatResolved;
  final ReplyMessageInfo? replyTo;

  const SendMessageRequest({
    this.message = "",
    required this.receiverId,
    required this.receiverName,
    this.attachments = const [],
    this.chatId,
    this.onChatResolved,
    this.type,
    this.replyTo,
  });

  @override
  String toString() {
    return 'SendMessageRequest('
        'message: $message, '
        'receiverId: $receiverId, '
        'receiverName: $receiverName, '
        'attachments: ${attachments.map((e) => e.path).toList()}, '
        'chatId: $chatId, '
        'type: $type, '
        'replyTo: $replyTo'
        ')';
  }
}
