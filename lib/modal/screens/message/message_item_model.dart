import 'package:my_app/core/database.dart';
import 'package:my_app/modal/message_reaction_modal.dart';
import 'package:my_app/modal/screens/message/message_modal.dart';
import 'package:my_app/modal/tables/chat_events_table.dart';

class MessageItemModel {
  final String id;
  final String message;
  final bool isSender;
  final MessageStatus? status;
  final int timestamp;
  final String senderName;
  final bool isGroupChat;
  final List<MediaTableData> attachments;
  final ChatEventAlignment? eventAlignment;
  final bool isGrouped;
  final String? replyToId;
  final String? replyToSenderName;
  final String? replyToMessage;
  final List<ReactionGroup> reactions;

  const MessageItemModel({
    this.id = '',
    required this.message,
    required this.isSender,
    required this.timestamp,
    required this.senderName,
    this.status,
    this.isGroupChat = false,
    this.attachments = const [],
    this.eventAlignment,
    this.isGrouped = false,
    this.replyToId,
    this.replyToSenderName,
    this.replyToMessage,
    this.reactions = const [],
  });

  MessageItemModel copyWith({
    String? id,
    String? message,
    bool? isSender,
    MessageStatus? status,
    int? timestamp,
    String? senderName,
    bool? isGroupChat,
    List<MediaTableData>? attachments,
    ChatEventAlignment? eventAlignment,
    bool? isGrouped,
    String? replyToId,
    String? replyToSenderName,
    String? replyToMessage,
    List<ReactionGroup>? reactions,
  }) {
    return MessageItemModel(
      id: id ?? this.id,
      message: message ?? this.message,
      isSender: isSender ?? this.isSender,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      senderName: senderName ?? this.senderName,
      isGroupChat: isGroupChat ?? this.isGroupChat,
      attachments: attachments ?? this.attachments,
      eventAlignment: eventAlignment ?? this.eventAlignment,
      isGrouped: isGrouped ?? this.isGrouped,
      replyToId: replyToId ?? this.replyToId,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      reactions: reactions ?? this.reactions,
    );
  }
}
