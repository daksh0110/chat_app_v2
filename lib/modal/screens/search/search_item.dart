import 'package:my_app/modal/upload_responses/upload_attachment.dart';

class SearchItem {
  final String id;
  final String name;
  final String? bio;
  final String? profilePicUrl;
  final String? email;
  final UploadAttachment? media;
  final String? actorType;
  final String? relationshipStatus;

  SearchItem({
    required this.id,
    required this.name,
    this.bio,
    this.profilePicUrl,
    this.email = "",
    this.media,
    this.actorType,
    this.relationshipStatus = "NONE",
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      id: json['_id'],
      name: json['name'],
      bio: json['bio'],
      profilePicUrl: json['profile_picture'],
      email: json["email"],
      media: json['media'] != null
          ? UploadAttachment.fromJson(json['media'] as Map<String, dynamic>)
          : null,
      actorType: json['actor_type'],
      relationshipStatus:
          json['relationship_status'] ?? json['status'] ?? "NONE",
    );
  }
}
