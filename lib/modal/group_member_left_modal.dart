class GroupMemberLeftModal {
  final String chatId;
  final String userId;
  final String memberName;
  final String? promotedAdminId;
  final int? sequence;

  GroupMemberLeftModal({
    required this.chatId,
    required this.userId,
    this.memberName = '',
    this.promotedAdminId,
    this.sequence,
  });

  factory GroupMemberLeftModal.fromJson(Map<String, dynamic> json) {
    return GroupMemberLeftModal(
      chatId: json['chat_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      memberName: json['member_name'] as String? ?? '',
      promotedAdminId: json['promoted_admin_id'] as String?,
      sequence: json['sequence'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'user_id': userId,
        'member_name': memberName,
        'promoted_admin_id': promotedAdminId,
        'sequence': sequence,
      };
}

