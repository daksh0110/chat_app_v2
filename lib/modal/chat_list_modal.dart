class ChatListModal {
  final String id;
  final String chatId;
  final String? name;
  final String? profilePicUrl;
  final String lastMessage;
  final String lastMessageTime;
  final int unReadCount;
  final String type;
  final String? bio;
  final String? receiverId;
  final bool isPinned;
  final bool isArchived;
  final bool isMuted;

  ChatListModal({
    required this.id,
    required this.chatId,
    this.name,
    this.profilePicUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unReadCount = 0,
    this.type = "DIRECT",
    this.bio,
    this.receiverId,
    this.isPinned = false,
    this.isArchived = false,
    this.isMuted = false,
  });
}
