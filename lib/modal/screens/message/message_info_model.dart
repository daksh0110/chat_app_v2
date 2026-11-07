class MessageRecipientStatus {
  final String userId;
  final String name;
  final String? profilePicUrl;
  final String status;
  final int? deliveredAt;
  final int? readAt;

  const MessageRecipientStatus({
    required this.userId,
    required this.name,
    this.profilePicUrl,
    required this.status,
    this.deliveredAt,
    this.readAt,
  });
}

class MessageInfoData {
  final List<MessageRecipientStatus> readBy;
  final List<MessageRecipientStatus> deliveredTo;
  final List<MessageRecipientStatus> remaining;
  final bool isGroup;
  final int totalParticipants;

  const MessageInfoData({
    required this.readBy,
    required this.deliveredTo,
    required this.remaining,
    required this.isGroup,
    required this.totalParticipants,
  });
}
