import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/util/getDatelabel.dart';
import 'package:my_app/core/util/status_map.dart';
import 'package:my_app/modal/screens/message/chat_timeline_event.dart';
import 'package:my_app/modal/screens/message/message_item_model.dart';
import 'package:my_app/modal/tables/chat_events_table.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:drift/drift.dart';

export 'package:my_app/modal/screens/message/chat_timeline_event.dart';

String getOverallStatus(
  List<MessageStatusTableData> statuses, {
  String? senderId,
  String fallback = "sending",
}) {
  final filteredStatuses = senderId == null
      ? statuses
      : statuses.where((s) => s.userId != senderId).toList();

  final effectiveStatuses = filteredStatuses.isNotEmpty
      ? filteredStatuses
      : statuses;

  if (effectiveStatuses.isEmpty) return fallback;
  if (effectiveStatuses.any((s) => s.status == "failed")) return "failed";
  if (effectiveStatuses.every((s) => s.status == "read")) return "read";
  if (effectiveStatuses.any((s) => s.status == "sending")) return "sending";

  final allDelivered = effectiveStatuses.every(
    (s) => s.status == "delivered" || s.status == "read",
  );
  if (allDelivered) return "delivered";
  if (effectiveStatuses.any((s) => s.status == "sent")) return "sent";

  return fallback;
}

class _TimelineEventGroup {
  final ChatEventsTableData event;
  final Message? message;
  final ChatParticipant? participant;
  final UsersTableData? user;
  final ChatListTableData? chat;
  final List<MessageStatusTableData> statuses = [];
  final List<MediaTableData> attachments = [];

  _TimelineEventGroup({
    required this.event,
    this.message,
    this.participant,
    this.user,
    this.chat,
  });
}

List<ChatTimelineEvent> _buildTimelineEventsFromGroups(
  Iterable<_TimelineEventGroup> groups,
  String? currentUserId,
) {
  final List<ChatTimelineEvent> events = [];
  String? previousDateLabel;
  MessageWithSender? previousMessage;

  for (final group in groups) {
    final event = group.event;
    final currentTimestamp = event.createdAt.millisecondsSinceEpoch;
    final currentDateLabel = getDateLabel(currentTimestamp);

    // Date separator banner ("Today", "Yesterday", etc.)
    if (currentDateLabel != previousDateLabel) {
      events.add(
        DateBannerTimelineEvent(
          label: currentDateLabel,
          timestamp: currentTimestamp,
        ),
      );
      previousDateLabel = currentDateLabel;
      previousMessage = null;
    }

    if (event.type == ChatEventType.banner) {
      events.add(
        BannerTimelineEvent(
          id: event.id,
          text: event.contentId,
          alignment: event.alignment,
          timestamp: currentTimestamp,
        ),
      );
      previousMessage = null;
    } else if (event.type == ChatEventType.message && group.message != null) {
      final message = group.message!;
      final isSender = message.senderId == currentUserId;
      final overallStatus = getOverallStatus(
        group.statuses,
        senderId: message.senderId,
        fallback: message.serverId != null ? "sent" : "sending",
      );

      final isGrouped =
          previousMessage != null &&
          previousMessage.message.senderId == message.senderId &&
          (currentTimestamp - previousMessage.timelineTimestamp).abs() <
              5 * 60 * 1000;

      final senderName = isSender
          ? "You"
          : (group.user?.name != null && group.user!.name.isNotEmpty
                ? group.user!.name
                : (group.participant?.userId ?? message.senderId));

      final rawMessage = MessageWithSender(
        message: message,
        participant:
            group.participant ??
            ChatParticipant(
              chatId: message.chatId,
              userId: message.senderId,
              role: "MEMBER",
            ),
        statuses: group.statuses,
        attachments: group.attachments,
        overallStatus: overallStatus,
        isGroupChat: group.chat?.type == "GROUP",
        name: group.user?.name,
        event: event,
      );

      events.add(
        MessageTimelineEvent(
          rawMessage: rawMessage,
          model: MessageItemModel(
            attachments: group.attachments,
            message: message.message,
            isSender: isSender,
            status: isSender ? statusMap(overallStatus) : statusMap("sending"),
            timestamp: currentTimestamp,
            senderName: senderName,
            isGroupChat: group.chat?.type == "GROUP",
            isGrouped: isGrouped,
            eventAlignment: event.alignment,
          ),
        ),
      );

      previousMessage = rawMessage;
    }
  }

  // Reverse so index 0 is latest message for ListView(reverse: true)
  return events.reversed.toList();
}

final chatMessagesProvider =
    StreamProvider.family<
      List<ChatTimelineEvent>,
      ({String chatId, String receiverId})
    >((ref, args) {
      final db = ref.watch(databaseProvider);
      final currentUserId = ref.watch(userPreferenceTableProvider).value;

      final localChatId = args.chatId.isNotEmpty
          ? args.chatId
          : "local_${args.receiverId}";

      try {
        final query = db.select(db.chatEventsTable).join([
          leftOuterJoin(
            db.messages,
            db.messages.id.equalsExp(db.chatEventsTable.contentId) |
                db.messages.serverId.equalsExp(db.chatEventsTable.contentId),
          ),
          leftOuterJoin(
            db.chatParticipants,
            db.chatParticipants.userId.equalsExp(db.messages.senderId) &
                db.chatParticipants.chatId.equalsExp(db.messages.chatId),
          ),
          leftOuterJoin(
            db.messageStatusTable,
            db.messageStatusTable.messageId.equalsExp(db.messages.serverId),
          ),
          leftOuterJoin(
            db.mediaTable,
            db.mediaTable.actorId.equalsExp(db.messages.serverId) |
                db.mediaTable.actorId.equalsExp(db.messages.id),
          ),
          leftOuterJoin(
            db.usersTable,
            db.usersTable.userId.equalsExp(db.messages.senderId),
          ),
          leftOuterJoin(
            db.chatListTable,
            db.chatListTable.chatId.equalsExp(db.chatEventsTable.chatId),
          ),
        ]);

        query.where(
          db.chatEventsTable.chatId.equals(args.chatId) |
              db.chatEventsTable.chatId.equals(localChatId),
        );

        // Native database sorting using indexed createdAt column
        query.orderBy([OrderingTerm.asc(db.chatEventsTable.createdAt)]);

        return query.watch().map((rows) {
          final Map<String, _TimelineEventGroup> groups = {};

          for (final row in rows) {
            final event = row.readTable(db.chatEventsTable);
            final message = row.readTableOrNull(db.messages);
            final participant = row.readTableOrNull(db.chatParticipants);
            final status = row.readTableOrNull(db.messageStatusTable);
            final media = row.readTableOrNull(db.mediaTable);
            final user = row.readTableOrNull(db.usersTable);
            final chat = row.readTableOrNull(db.chatListTable);

            final group = groups.putIfAbsent(
              event.id,
              () => _TimelineEventGroup(
                event: event,
                message: message,
                participant: participant,
                user: user,
                chat: chat,
              ),
            );

            if (status != null) group.statuses.add(status);
            if (media != null) group.attachments.add(media);
          }

          return _buildTimelineEventsFromGroups(groups.values, currentUserId);
        });
      } catch (e, st) {
        debugPrint('chatMessagesProvider error: $e\n$st');
        return Stream.value([]);
      }
    });
