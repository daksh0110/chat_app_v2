import 'package:my_app/core/database.dart';
import 'package:my_app/modal/screens/message/message_item_model.dart';
import 'package:my_app/modal/tables/chat_events_table.dart';

class MessageWithSender {
  final Message message;
  final ChatParticipant participant;
  final List<MessageStatusTableData> statuses;
  final List<MediaTableData> attachments;
  final String overallStatus;
  final bool isGroupChat;
  final String? name;
  final ChatEventsTableData? event;

  MessageWithSender({
    required this.message,
    required this.participant,
    required this.statuses,
    required this.attachments,
    required this.overallStatus,
    this.isGroupChat = false,
    this.name = "",
    this.event,
  });

  int get timelineTimestamp =>
      event?.createdAt.millisecondsSinceEpoch ?? message.createdAt;
}

sealed class ChatTimelineEvent {
  int get timestamp;
  const ChatTimelineEvent();
}

class DateBannerTimelineEvent extends ChatTimelineEvent {
  final String label;
  @override
  final int timestamp;

  const DateBannerTimelineEvent({
    required this.label,
    required this.timestamp,
  });
}

class MessageTimelineEvent extends ChatTimelineEvent {
  final MessageItemModel model;
  final MessageWithSender rawMessage;

  @override
  int get timestamp => model.timestamp;

  const MessageTimelineEvent({
    required this.model,
    required this.rawMessage,
  });
}

class BannerTimelineEvent extends ChatTimelineEvent {
  final String id;
  final String text;
  final ChatEventAlignment alignment;
  @override
  final int timestamp;

  const BannerTimelineEvent({
    required this.id,
    required this.text,
    required this.alignment,
    required this.timestamp,
  });
}

/// Helper models used when merging messages and system banner events chronologically.
sealed class RawTimelineItem {
  int get timestamp;
  const RawTimelineItem();
}

class RawMessageItem extends RawTimelineItem {
  final MessageWithSender message;
  const RawMessageItem(this.message);

  @override
  int get timestamp => message.timelineTimestamp;
}

class RawBannerItem extends RawTimelineItem {
  final ChatEventsTableData banner;
  const RawBannerItem(this.banner);

  @override
  int get timestamp => banner.createdAt.millisecondsSinceEpoch;
}
