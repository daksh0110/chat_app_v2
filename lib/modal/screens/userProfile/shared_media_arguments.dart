class SharedMediaArguments {
  final String chatId;
  final String title;
  final bool isGroupChat;

  const SharedMediaArguments({
    required this.chatId,
    required this.title,
    this.isGroupChat = false,
  });
}

