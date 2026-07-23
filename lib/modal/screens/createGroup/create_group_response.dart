import 'package:my_app/modal/upload_responses/upload_attachment.dart';

class CreateGroupResponse {
  final bool success;
  final String message;
  final GroupData? data;

  CreateGroupResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateGroupResponse.fromJson(Map<String, dynamic> json) {
    final bool success = json.containsKey('success')
        ? json['success'] == true
        : true;

    return CreateGroupResponse(
      success: success,
      message: json['message'] ?? '',
      data: GroupData.fromJson(json),
    );
  }
  @override
  String toString() {
    return 'CreateGroupResponse(success: $success, message: $message, data: $data)';
  }
}

class GroupData {
  final String chatId;
  final String name;
  final String profilePictureUrl;
  final String description;
  final String type;
  final List<Participant> participants;
  final UploadAttachment? media;
  final String? bio;

  GroupData({
    required this.chatId,
    this.name = "unknown",
    this.profilePictureUrl = "",
    this.description = "",
    required this.type,
    required this.participants,
    this.media,
    this.bio,
  });

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
      chatId: json['chat_id'] ?? '',
      name: json['name'] ?? '',
      profilePictureUrl: json['profile_pic_url'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'GROUP',
      participants: (json['participants'] as List? ?? [])
          .map((e) => Participant.fromJson(e))
          .toList(),
      media: json['media'] != null
          ? UploadAttachment.fromJson(json['media'] as Map<String, dynamic>)
          : null,
      bio: json['bio'] ?? "",
    );
  }
  @override
  String toString() {
    return 'GroupData(chatId: $chatId, name: $name, profilePictureUrl: $profilePictureUrl, description: $description, type: $type, participants: $participants, media: $media, bio: $bio)';
  }
}

class Participant {
  final String userId;
  final String name;
  final String profilePictureUrl;
  final String role;
  final String chatId;
  final UploadAttachment? media;
  final String? email;
  final String? bio;

  Participant({
    required this.userId,
    this.name = "unknown",
    this.profilePictureUrl = "",
    required this.role,
    required this.chatId,
    this.media,
    this.email,
    this.bio,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profilePictureUrl: json['profile_pic_url'] ?? '',
      role: json['role'] ?? 'MEMBER',
      chatId: json['chat_id'] ?? '',
      media: json['media'] != null
          ? UploadAttachment.fromJson(json['media'] as Map<String, dynamic>)
          : null,
      bio: json["bio"],
    );
  }
  @override
  String toString() {
    return 'Participant(userId: $userId, name: $name, email: $email, role: $role, chatId: $chatId, profilePictureUrl: $profilePictureUrl, media: $media, bio: $bio)';
  }
}
