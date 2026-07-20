import 'package:my_app/modal/upload_responses/upload_attachment.dart';

class GroupCreationModal {
  final String name;
  final String bio;
  final List<String> userIds;
  final UploadAttachment? media;

  GroupCreationModal({
    required this.name,
    required this.bio,
    required this.userIds,
    this.media,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'userIds': userIds,
      'media': media?.toJson(),
    };
  }

  @override
  String toString() {
    return 'GroupCreationModal('
        'name: $name, '
        'bio: $bio, '
        'userIds: $userIds, '
        'media: $media'
        ')';
  }
}
