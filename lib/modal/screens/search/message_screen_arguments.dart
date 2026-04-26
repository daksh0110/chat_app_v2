class MessageScreenArguments {
  final String chatId;
  final String receiverId;
  final String name;
  final String? profilePicUrl;

  MessageScreenArguments({
    this.chatId = "",
    required this.name,
    this.profilePicUrl,
    this.receiverId = "",
  });
}

