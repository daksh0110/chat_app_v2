import 'package:my_app/modal/upload_responses/upload_attachment.dart';

class GroupInfoModal {
  final String chatId;
  final String name;
  final String? bio;
  final String? type;
  final UploadAttachment? media;

  GroupInfoModal({
    required this.chatId,
    required this.name,
    this.bio,
    this.type,
    this.media,
  });

  factory GroupInfoModal.fromJson(Map<String, dynamic> json) {
    return GroupInfoModal(
      chatId: json['chat_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String?,
      type: json['type'] as String?,
      media: json['media'] != null && json['media'] is Map
          ? UploadAttachment.fromJson(Map<String, dynamic>.from(json['media']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'name': name,
        'bio': bio,
        'type': type,
        'media': media?.toJson(),
      };
}

