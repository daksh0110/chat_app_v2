import 'package:intl/intl.dart';
import 'package:my_app/core/database.dart';

class ChatListModal {
  final String id;
  final String chatId;
  final String name;
  final String? profilePicUrl;
  final String lastMessage;
  final String lastMessageTime;
  final int unReadCount;

  ChatListModal({
    required this.id,
    required this.chatId,
    required this.name,
    this.profilePicUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unReadCount = 0,
  });

  factory ChatListModal.fromDrift(ChatListTableData data) {
    return ChatListModal(
      id: data.id.toString(),
      chatId: data.chatId.toString(),
      name: data.name,
      profilePicUrl: data.profilePicUrl,
      lastMessage: data.lastMessage ?? "",
      lastMessageTime: DateFormat(
        "HH:mm",
      ).format(DateTime.fromMillisecondsSinceEpoch(data.lastMessageTime!)),
      unReadCount: data.unReadCount,
    );
  }
}

