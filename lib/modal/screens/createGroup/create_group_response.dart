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
}

class GroupData {
  final String chatId;
  final String name;
  final String profilePictureUrl;
  final String description;
  final String type;
  final List<Participant> participants;
  final UploadAttachment? media;

  GroupData({
    required this.chatId,
    this.name = "unknown",
    this.profilePictureUrl = "",
    this.description = "",
    required this.type,
    required this.participants,
    this.media,
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
    );
  }
}

class Participant {
  final String userId;
  final String name;
  final String profilePictureUrl;
  final String role;
  final String chatId;
  final UploadAttachment? media;

  Participant({
    required this.userId,
    this.name = "unknown",
    this.profilePictureUrl = "",
    required this.role,
    required this.chatId,
    this.media,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      profilePictureUrl: json['profile_pic_url'] ?? '',
      role: json['role'] ?? 'MEMBER',
      chatId: json['chat_id'] ?? '',
      media: json['media'] != null
          ? UploadAttachment.fromJson(json['media'] as Map<String, dynamic>)
          : null,
    );
  }
}
