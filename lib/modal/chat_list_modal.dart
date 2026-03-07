import 'package:intl/intl.dart';
import 'package:my_app/core/database.dart';

class ChatListModal {
  final String id;
  final String name;
  final String profilePic;
  final String lastMessage;
  final String lastMessageTime;
  final int unReadCount;

  ChatListModal({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unReadCount = 0,
  });

  factory ChatListModal.fromDrift(ChatListTableData data) {
    return ChatListModal(
      id: data.userId.toString(),
      name: data.name,
      profilePic: "assets/screens/home/user1.png",
      lastMessage: data.lastMessage ?? "",
      lastMessageTime: DateFormat(
        "HH:mm",
      ).format(DateTime.fromMillisecondsSinceEpoch(data.lastMessageTime!)),
      unReadCount: data.unReadCount,
    );
  }
}
