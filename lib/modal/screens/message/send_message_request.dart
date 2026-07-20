import 'package:image_picker/image_picker.dart';

class SendMessageRequest {
  final String message;
  final String receiverId;
  final String receiverName;
  final List<XFile> attachments;
  final String? chatId;
  final String? type;
  final void Function(String realChatId)? onChatResolved;

  const SendMessageRequest({
    this.message = "",
    required this.receiverId,
    required this.receiverName,
    this.attachments = const [],
    this.chatId,
    this.onChatResolved,
    this.type,
  });
  @override
  String toString() {
    return 'SendMessageRequest('
        'message: $message, '
        'receiverId: $receiverId, '
        'receiverName: $receiverName, '
        'attachments: ${attachments.map((e) => e.path).toList()}, '
        'chatId: $chatId, '
        'type: $type'
        ')';
  }
}
