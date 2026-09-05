import 'package:my_app/modal/upload_responses/upload_attachment.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final String? profilePic;
  final UploadAttachment? media;
  final String? relationshipStatus;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.profilePic,
    this.media,
    this.relationshipStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      bio: json["bio"],
      media: json['media'] != null
          ? UploadAttachment.fromJson(json['media'] as Map<String, dynamic>)
          : null,
    );
  }
}
