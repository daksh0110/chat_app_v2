import 'package:my_app/modal/upload_responses/upload_attachment.dart';

class GroupProfileUpdatedModal {
  final String chatId;
  final String? name;
  final String? bio;
  final String? image;
  final UploadAttachment? media;
  final String actorId;
  final String actorName;
  final int? sequence;

  GroupProfileUpdatedModal({
    required this.chatId,
    this.name,
    this.bio,
    this.image,
    this.media,
    this.actorId = '',
    this.actorName = '',
    this.sequence,
  });

  factory GroupProfileUpdatedModal.fromJson(Map<String, dynamic> json) {
    UploadAttachment? mediaAttachment;
    if (json['media'] is Map) {
      final mediaMap = Map<String, dynamic>.from(json['media'] as Map);
      mediaAttachment = UploadAttachment(
        contentType: mediaMap['content_type'] as String? ?? 'image/jpeg',
        key: mediaMap['key'] as String? ?? '',
        type: mediaMap['type'] as String? ?? 'image',
        name: mediaMap['name'] as String? ?? 'group_photo',
        location: (json['image'] as String?)?.isNotEmpty == true
            ? json['image'] as String?
            : (mediaMap['key'] as String?),
      );
    }

    return GroupProfileUpdatedModal(
      chatId: json['chat_id'] as String? ?? json['chatId'] as String? ?? '',
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      image: json['image'] as String?,
      media: mediaAttachment,
      actorId: json['actor_id'] as String? ?? json['actorId'] as String? ?? '',
      actorName:
          json['actor_name'] as String? ?? json['actorName'] as String? ?? '',
      sequence: json['sequence'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        if (name != null) 'name': name,
        if (bio != null) 'bio': bio,
        if (image != null) 'image': image,
        if (media != null)
          'media': {
            'content_type': media!.contentType,
            'key': media!.key,
            'type': media!.type,
            'name': media!.name,
          },
        'actor_id': actorId,
        'actor_name': actorName,
        if (sequence != null) 'sequence': sequence,
      };
}

