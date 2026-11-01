import 'package:my_app/modal/screens/createGroup/create_group_response.dart';

class GroupSyncModal {
  final String chatId;
  final String name;
  final String description;
  final String profilePicUrl;
  final List<Participant> participants;

  GroupSyncModal({
    required this.chatId,
    this.name = '',
    this.description = '',
    this.profilePicUrl = '',
    this.participants = const [],
  });

  factory GroupSyncModal.fromJson(Map<String, dynamic> json) {
    return GroupSyncModal(
      chatId: json['chat_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description:
          json['description'] as String? ?? json['bio'] as String? ?? '',
      profilePicUrl: json['profile_pic_url'] as String? ?? '',
      participants: (json['participants'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Participant.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'name': name,
        'description': description,
        'profile_pic_url': profilePicUrl,
      };
}

