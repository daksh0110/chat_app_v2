class GroupMemberRoleUpdatedModal {
  final String chatId;
  final String userId;
  final String role;
  final String actorId;
  final String actorName;
  final String memberName;
  final int? sequence;

  GroupMemberRoleUpdatedModal({
    required this.chatId,
    required this.userId,
    required this.role,
    this.actorId = '',
    this.actorName = '',
    this.memberName = '',
    this.sequence,
  });

  factory GroupMemberRoleUpdatedModal.fromJson(Map<String, dynamic> json) {
    return GroupMemberRoleUpdatedModal(
      chatId: json['chat_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      role: json['role'] as String? ?? 'MEMBER',
      actorId: json['actor_id'] as String? ?? '',
      actorName: json['actor_name'] as String? ?? '',
      memberName: json['member_name'] as String? ?? '',
      sequence: json['sequence'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'user_id': userId,
        'role': role,
        'actor_id': actorId,
        'actor_name': actorName,
        'member_name': memberName,
        'sequence': sequence,
      };
}

