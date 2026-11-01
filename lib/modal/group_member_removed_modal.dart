class GroupMemberRemovedModal {
  final String chatId;
  final String userId;
  final String actorId;
  final String actorName;
  final String memberName;
  final int? sequence;

  GroupMemberRemovedModal({
    required this.chatId,
    required this.userId,
    this.actorId = '',
    this.actorName = '',
    this.memberName = '',
    this.sequence,
  });

  factory GroupMemberRemovedModal.fromJson(Map<String, dynamic> json) {
    return GroupMemberRemovedModal(
      chatId: json['chat_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      actorId: json['actor_id'] as String? ?? '',
      actorName: json['actor_name'] as String? ?? '',
      memberName: json['member_name'] as String? ?? '',
      sequence: json['sequence'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'user_id': userId,
        'actor_id': actorId,
        'actor_name': actorName,
        'member_name': memberName,
        'sequence': sequence,
      };
}

