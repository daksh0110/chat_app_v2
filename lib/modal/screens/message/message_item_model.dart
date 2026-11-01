import 'package:my_app/core/database.dart';
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
  });
}
