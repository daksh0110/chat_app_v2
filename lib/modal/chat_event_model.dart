import 'package:my_app/modal/tables/chat_events_table.dart';

class ChatEventModel {
  final String id;
  final String chatId;
  final ChatEventType type;
  final String contentId;
  final ChatEventAlignment alignment;
  final DateTime createdAt;

  const ChatEventModel({
    required this.id,
    required this.chatId,
    required this.type,
    required this.contentId,
    required this.alignment,
    required this.createdAt,
  });

  factory ChatEventModel.fromJson(Map<String, dynamic> json) {
    return ChatEventModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      type: ChatEventType.values.byName(json['type'] as String),
      contentId: json['contentId'] as String,
      alignment: ChatEventAlignment.values.byName(json['alignment'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'type': type.name,
      'contentId': contentId,
      'alignment': alignment.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
