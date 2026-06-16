import 'package:my_app/modal/upload_responses/upload_attachment.dart';

class SearchItem {
  final String id;
  final String name;
  final String subtitle;
  final String? bio;
  final String? profilePicUrl;
  final String? email;
  final UploadAttachment? media;

  SearchItem({
    required this.id,
    required this.name,
    this.subtitle = "",
    this.bio,
    this.profilePicUrl,
    this.email = "",
    this.media,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      id: json['_id'],
      name: json['name'],
      subtitle: json["subtitle"] ?? json["email"],
      bio: json['bio'],
      profilePicUrl: json['profile_picture'],
      email: json["email"],
      media: json['media'] != null
          ? UploadAttachment.fromJson(json['media'] as Map<String, dynamic>)
          : null,
    );
  }
}
