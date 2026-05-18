import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:drift/drift.dart';

class MessageWithSender {
  final Message message;
  final ChatParticipant participant;
  final List<MessageStatusTableData> statuses;

  final String overallStatus;
  final bool isGroupChat;

  MessageWithSender({
    required this.message,
    required this.participant,
    required this.statuses,
    required this.overallStatus,
    this.isGroupChat = false,
  });
}

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

  if (effectiveStatuses.isEmpty) {
    return fallback;
  }

  if (effectiveStatuses.any((s) => s.status == "failed")) {
    return "failed";
  }

  if (effectiveStatuses.every((s) => s.status == "read")) {
    return "read";
  }

  if (effectiveStatuses.any((s) => s.status == "sending")) {
    return "sending";
  }

  final allDelivered = effectiveStatuses.every(
    (s) => s.status == "delivered" || s.status == "read",
  );

  if (allDelivered) {
    return "delivered";
  }

  if (effectiveStatuses.any((s) => s.status == "sent")) {
    return "sent";
  }

  return fallback;
}

final chatMessagesProvider =
    StreamProvider.family<
      List<MessageWithSender>,
      ({String chatId, String receiverId})
    >((ref, args) {
      final db = ref.watch(databaseProvider);

      final localChatId = args.chatId.isNotEmpty
          ? args.chatId
          : "local_${args.receiverId}";

      final query = db.select(db.messages).join([
        innerJoin(
          db.chatParticipants,
          db.chatParticipants.userId.equalsExp(db.messages.senderId) &
              db.chatParticipants.chatId.equalsExp(db.messages.chatId),
        ),

        leftOuterJoin(
          db.messageStatusTable,
          db.messageStatusTable.messageId.equalsExp(db.messages.serverId),
        ),
      ]);

      query.where(
        db.messages.chatId.equals(args.chatId) |
            db.messages.chatId.equals(localChatId),
      );

      query.orderBy([OrderingTerm.asc(db.messages.createdAt)]);

      return query.watch().map((rows) {
        final Map<String, MessageWithSender> grouped = {};

        for (final row in rows) {
          final message = row.readTable(db.messages);

          final participant = row.readTable(db.chatParticipants);

          final status = row.readTableOrNull(db.messageStatusTable);

          final key = message.id;

          if (!grouped.containsKey(key)) {
            grouped[key] = MessageWithSender(
              message: message,
              participant: participant,
              statuses: [],
              overallStatus: "sent",
              isGroupChat: false,
            );
          }

          if (status != null) {
            grouped[key]!.statuses.add(status);
          }
        }

        return grouped.values.map((item) {
          return MessageWithSender(
            message: item.message,
            participant: item.participant,
            statuses: item.statuses,
            overallStatus: getOverallStatus(
              item.statuses,
              senderId: item.message.senderId,
              fallback: item.message.messageStatus,
            ),
            isGroupChat: item.isGroupChat,
          );
        }).toList();
      });
    });
