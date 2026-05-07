class MessageScreenArguments {
  final String chatId;
  final String receiverId;
  final String name;
  final String? profilePicUrl;
  final String isGroupChat;

  MessageScreenArguments({
    this.chatId = "",
    required this.name,
    this.profilePicUrl,
    this.receiverId = "",
    this.isGroupChat = "dm",
  });
}
