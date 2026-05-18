class UserProfileArguments {
  final String id;
  final bool isGroupChat;
  final String? name;
  final String? profilePicUrl;

  UserProfileArguments({
    required this.id,
    this.isGroupChat = false,
    this.name,
    this.profilePicUrl,
  });
}
