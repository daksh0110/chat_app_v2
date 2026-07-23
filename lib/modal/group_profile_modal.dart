class GroupProfile {
  final String chatId;
  final String name;
  final String description;
  final String? profilePicUrl;
  final List<GroupMember> members;

  GroupProfile({
    required this.chatId,
    required this.name,
    required this.description,
    this.profilePicUrl,
    required this.members,
  });
}

class GroupMember {
  final String userId;
  final String name;
  final String? profilePicUrl;
  final String role;

  GroupMember({
    required this.userId,
    required this.name,
    this.profilePicUrl,
    required this.role,
  });
}
