import 'package:my_app/modal/upload_responses/upload_attachment.dart';

class UserProfileModal {
  final String? chatId;
  final String? name;
  final String? profilePic;
  final String? email;
  final String? bio;
  final String? id;
  final List<MediaShared> mediaShared;
  final int totalMediaCount;
  final String? relationshipStatus;

  UserProfileModal({
    this.chatId,
    this.name,
    this.profilePic,
    this.email,
    this.bio,
    this.id,
    this.mediaShared = const [],
    this.totalMediaCount = 0,
    this.relationshipStatus,
  });

  @override
  String toString() {
    return 'UserProfileModal('
        'chatId: $chatId, '
        'name: $name, '
        'profilePic: $profilePic, '
        'email: $email, '
        'bio: $bio, '
        'id: $id, '
        'mediaShared: $mediaShared, '
        'totalMediaCount: $totalMediaCount, '
        'relationshipStatus: $relationshipStatus'
        ')';
  }
}

class MediaShared extends UploadAttachment {
  final String userId;
  final String userName;

  MediaShared({
    required this.userId,
    required this.userName,
    super.actorId,
    super.contentType = "",
    super.key = "",
    super.name,
    super.location,
    super.type = "",
  });

  @override
  String toString() {
    return 'MediaShared('
        'userId: $userId, '
        'userName: $userName, '
        'actorId: $actorId, '
        'contentType: $contentType, '
        'key: $key, '
        'name: $name, '
        'location: $location, '
        'type: $type'
        ')';
  }
}
