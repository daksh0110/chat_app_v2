import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/util/parse_time.dart';
import 'package:my_app/modal/screens/message/message_delivered_response.dart';
import 'package:my_app/modal/screens/message/message_read_response.dart';
import 'package:my_app/modal/screens/message/message_status.dart';
import 'package:my_app/providers/database_provider.dart';

final messageStatusTableProvider =
    NotifierProvider<MessageStatusTableProvider, void>(
      MessageStatusTableProvider.new,
    );

class MessageStatusTableProvider extends Notifier {
  @override
  build() {}

  Future<void> bulkCreateMessageStatus(
    List<MessageStatus> statuses,
    String messageId,
  ) async {
    debugPrint("reached at bulkCreateMessageStatus");
    final db = ref.read(databaseProvider);
    await db.managers.messageStatusTable.bulkCreate(
      (o) => statuses.map((status) {
        return o(
          messageId: messageId,
          userId: status.userId,
          status: Value(status.status),
          createdAt: parseTimestamp(status.createdAt),
          updatedAt: parseTimestamp(status.updatedAt),
          deliveredAt: Value(
            status.deliveredAt != null
                ? parseTimestamp(status.deliveredAt)
                : null,
          ),
          readAt: Value(
            status.readAt != null ? parseTimestamp(status.readAt) : null,
          ),
        );
      }).toList(),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteMessageStatus(String messageId) async {
    final db = ref.read(databaseProvider);
    await db.managers.messageStatusTable
        .filter((f) => f.messageId.equals(messageId))
        .delete();
  }

  Future<void> createLocalParticipantsStatus(
    String tempId,
    String currentUserId,
    String chatId,
    int now,
  ) async {
    final db = ref.read(databaseProvider);
    final participants = await db.managers.chatParticipants
        .filter((f) => f.chatId.equals(chatId))
        .get();

    await db.managers.messageStatusTable.bulkCreate(
      (o) => participants.map((p) {
        final isMe = p.userId == currentUserId;
        return o(
          messageId: tempId,
          userId: p.userId,
          status: Value(isMe ? "sent" : "sending"),
          createdAt: now,
          updatedAt: now,
          deliveredAt: Value(isMe ? now : null),
          readAt: Value(isMe ? now : null),
        );
      }).toList(),
    );
  }

  Future<void> updateMessageStatus(
    MessageDeliveredResponse response,
    int Function(String) statusRank,
  ) async {
    final db = ref.read(databaseProvider);

    final status = response.messageStatus;

    final existingRow =
        await (db.select(db.messageStatusTable)..where(
              (tbl) =>
                  tbl.messageId.equals(status.messageId) &
                  tbl.userId.equals(status.userId),
            ))
            .getSingleOrNull();

    if (existingRow == null) {
      throw Exception("Status row not found yet, retrying...");
    }

    if (statusRank(status.status) <= statusRank(existingRow.status)) {
      return;
    }

    await (db.update(db.messageStatusTable)..where(
          (tbl) =>
              tbl.messageId.equals(status.messageId) &
              tbl.userId.equals(status.userId),
        ))
        .write(
          MessageStatusTableCompanion(
            status: Value(status.status),
            deliveredAt: Value(parseTimestamp(status.deliveredAt)),
            updatedAt: Value(parseTimestamp(status.updatedAt)),
          ),
        );
  }

  Future<List<MessageStatusTableData>> getUnreadStatusesForChat({
    required String chatId,
    required String userId,
  }) async {
    final db = ref.read(databaseProvider);

    final query = db.select(db.messageStatusTable).join([
      innerJoin(
        db.messages,
        db.messages.id.equalsExp(db.messageStatusTable.messageId),
      ),
    ]);

    query.where(
      db.messageStatusTable.userId.equals(userId) &
          db.messageStatusTable.status.equals("read").not() &
          db.messages.chatId.equals(chatId),
    );

    final rows = await query.get();

    return rows.map((row) => row.readTable(db.messageStatusTable)).toList();
  }

  Future<void> updateMessageReadStatus(
    MessageReadResponse response,
    int Function(String) statusRank,
  ) async {
    final db = ref.read(databaseProvider);

    final status = response.messageStatus;

    final existingRow =
        await (db.select(db.messageStatusTable)..where(
              (tbl) =>
                  tbl.messageId.equals(status.messageId) &
                  tbl.userId.equals(status.userId),
            ))
            .getSingleOrNull();

    if (existingRow == null) {
      throw Exception("Status row not found yet, retrying...");
    }

    if (statusRank(status.status) <= statusRank(existingRow.status)) {
      return;
    }

    await (db.update(db.messageStatusTable)..where(
          (tbl) =>
              tbl.messageId.equals(status.messageId) &
              tbl.userId.equals(status.userId),
        ))
        .write(
          MessageStatusTableCompanion(
            status: Value(status.status),
            readAt: Value(parseTimestamp(status.readAt)),
            updatedAt: Value(parseTimestamp(status.updatedAt)),
          ),
        );
  }

  Future<void> bulkUpdateMessageReadStatus({
    required List<String> messageIds,
    required String userId,
    required int readAt,
  }) async {
    if (messageIds.isEmpty) return;

    final db = ref.read(databaseProvider);

    await (db.update(db.messageStatusTable)..where(
          (tbl) => tbl.userId.equals(userId) & tbl.messageId.isIn(messageIds),
        ))
        .write(
          MessageStatusTableCompanion(
            status: const Value("read"),
            readAt: Value(readAt),
            updatedAt: Value(readAt),
          ),
        );
  }
}
