class MessageScreenArguments {
  final String chatId;
  final String receiverId;
  final String name;
  final String profilePic;

  MessageScreenArguments({
    this.chatId = "",
    required this.name,
    this.profilePic = "",
    this.receiverId = "",
  });
}
