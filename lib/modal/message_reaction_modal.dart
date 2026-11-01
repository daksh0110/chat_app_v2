class ReactionUser {
  final String userId;
  final String name;

  const ReactionUser({
    required this.userId,
    required this.name,
  });

  factory ReactionUser.fromJson(Map<String, dynamic> json) {
    return ReactionUser(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
    };
  }
}

class ReactionGroup {
  final String emoji;
  final int count;
  final List<ReactionUser> users;
  final bool hasReactedByMe;

  const ReactionGroup({
    required this.emoji,
    required this.count,
    this.users = const [],
    this.hasReactedByMe = false,
  });

  factory ReactionGroup.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final usersList = (json['users'] as List? ?? [])
        .map((u) => ReactionUser.fromJson(Map<String, dynamic>.from(u)))
        .toList();
    final hasReacted =
        currentUserId != null &&
        usersList.any((u) => u.userId == currentUserId);

    return ReactionGroup(
      emoji: json['emoji']?.toString() ?? '',
      count: json['count'] is int
          ? json['count']
          : (int.tryParse(json['count']?.toString() ?? '') ?? usersList.length),
      users: usersList,
      hasReactedByMe: hasReacted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'count': count,
      'users': users.map((u) => u.toJson()).toList(),
    };
  }
}

class ReactionEventPayload {
  final String messageId;
  final String chatId;
  final String userId;
  final String emoji;
  final bool removed;
  final List<ReactionGroup> reactions;

  const ReactionEventPayload({
    required this.messageId,
    required this.chatId,
    required this.userId,
    required this.emoji,
    required this.removed,
    this.reactions = const [],
  });

  factory ReactionEventPayload.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    return ReactionEventPayload(
      messageId: json['message_id']?.toString() ?? '',
      chatId: json['chat_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
      removed: json['removed'] == true,
      reactions: (json['reactions'] as List? ?? [])
          .map(
            (r) => ReactionGroup.fromJson(
              Map<String, dynamic>.from(r),
              currentUserId: currentUserId,
            ),
          )
          .toList(),
    );
  }
}

