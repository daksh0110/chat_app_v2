class ChatListModal {
  final String id;
  final String name;
  final String profilePic;
  final String lastMessage;
  final String lastMessageAt;
  final int unReadCount;

  ChatListModal({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unReadCount = 0,
  });
}
