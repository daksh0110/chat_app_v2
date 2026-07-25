import 'package:my_app/modal/user_profile_modal.dart';

class GroupProfile {
  final String chatId;
  final String name;
  final String description;
  final String? profilePicUrl;
  final List<GroupMember> members;
  final List<MediaShared> mediaShared;
  final int totalMediaCount;

  GroupProfile({
    required this.chatId,
    required this.name,
    required this.description,
    this.profilePicUrl,
    required this.members,
    this.mediaShared = const [],
    this.totalMediaCount = 0,
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
