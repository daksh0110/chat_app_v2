import 'package:my_app/modal/upload_responses/upload_attachment.dart';

class GroupModal {
  final String id;
  final String? name;
  final String? bio;
  final String? profilePic;
  final UploadAttachment? media;

  GroupModal({
    required this.id,
    this.name,
    this.bio,
    this.profilePic,
    this.media,
  });
}
