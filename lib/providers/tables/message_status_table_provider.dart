import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/util/parse_time.dart';
import 'package:my_app/modal/screens/message/message_delivered_response.dart';
import 'package:my_app/modal/screens/message/message_info_model.dart';
import 'package:my_app/modal/screens/message/message_read_response.dart';
import 'package:my_app/modal/screens/message/message_status.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';

export 'package:my_app/modal/screens/message/message_info_model.dart';

final messageStatusTableProvider =
    NotifierProvider<MessageStatusTableProvider, void>(
      MessageStatusTableProvider.new,
    );

final messageInfoProvider = StreamProvider.autoDispose
    .family<
      MessageInfoData,
      ({String messageId, String? serverId, String chatId, bool isGroup})
    >((ref, args) {
      final db = ref.watch(databaseProvider);
      final currentUserId = ref.watch(userPreferenceTableProvider).value;

      return db.messageStatusTable.select().watch().asyncMap((_) async {
        final ids = <String>{
          args.messageId,
          if (args.serverId != null && args.serverId!.isNotEmpty)
            args.serverId!,
        };

        final msgRow =
            await (db.select(db.messages)..where(
                  (tbl) =>
                      tbl.id.equals(args.messageId) |
                      tbl.serverId.equals(args.messageId),
                ))
                .getSingleOrNull();

        if (msgRow != null) {
          ids.add(msgRow.id);
          if (msgRow.serverId != null && msgRow.serverId!.isNotEmpty) {
            ids.add(msgRow.serverId!);
          }
        }

        final statusRows = await (db.select(
          db.messageStatusTable,
        )..where((tbl) => tbl.messageId.isIn(ids))).get();

        final statusByUserId = <String, MessageStatusTableData>{
          for (final s in statusRows) s.userId: s,
        };

        final effectiveChatId = msgRow?.chatId.isNotEmpty == true
            ? msgRow!.chatId
            : args.chatId;

        if (args.isGroup) {
          final participantRows = await (db.select(db.chatParticipants).join([
            leftOuterJoin(
              db.usersTable,
              db.usersTable.userId.equalsExp(db.chatParticipants.userId),
            ),
            leftOuterJoin(
              db.mediaTable,
              db.mediaTable.actorId.equalsExp(db.chatParticipants.userId),
            ),
          ])..where(db.chatParticipants.chatId.equals(effectiveChatId))).get();

          final otherParticipants = participantRows.where((row) {
            final p = row.readTable(db.chatParticipants);
            return p.userId != currentUserId;
          }).toList();

          final List<MessageRecipientStatus> readBy = [];
          final List<MessageRecipientStatus> deliveredTo = [];
          final List<MessageRecipientStatus> remaining = [];
          final Set<String> processedUserIds = {};

          for (final row in otherParticipants) {
            final p = row.readTable(db.chatParticipants);
            if (processedUserIds.contains(p.userId)) continue;
            processedUserIds.add(p.userId);

            final u = row.readTableOrNull(db.usersTable);
            final m = row.readTableOrNull(db.mediaTable);
            final name = (u != null && u.name.isNotEmpty) ? u.name : p.userId;
            final pic = m?.location ?? m?.url;
            final s = statusByUserId[p.userId];

            final recipient = MessageRecipientStatus(
              userId: p.userId,
              name: name,
              profilePicUrl: pic,
              status: s?.status ?? 'sending',
              deliveredAt: s?.deliveredAt,
              readAt: s?.readAt,
            );

            if (s?.readAt != null || s?.status == 'read') {
              readBy.add(recipient);
            } else if (s?.deliveredAt != null || s?.status == 'delivered') {
              deliveredTo.add(recipient);
            } else {
              remaining.add(recipient);
            }
          }

          for (final s in statusRows) {
            if (s.userId == currentUserId ||
                processedUserIds.contains(s.userId)) {
              continue;
            }
            processedUserIds.add(s.userId);

            final userRow = await (db.select(
              db.usersTable,
            )..where((tbl) => tbl.userId.equals(s.userId))).getSingleOrNull();
            final mediaRow = await (db.select(
              db.mediaTable,
            )..where((tbl) => tbl.actorId.equals(s.userId))).getSingleOrNull();

            final recipient = MessageRecipientStatus(
              userId: s.userId,
              name: userRow?.name ?? s.userId,
              profilePicUrl: mediaRow?.location ?? mediaRow?.url,
              status: s.status,
              deliveredAt: s.deliveredAt,
              readAt: s.readAt,
            );

            if (s.readAt != null || s.status == 'read') {
              readBy.add(recipient);
            } else if (s.deliveredAt != null || s.status == 'delivered') {
              deliveredTo.add(recipient);
            } else {
              remaining.add(recipient);
            }
          }

          readBy.sort((a, b) => (b.readAt ?? 0).compareTo(a.readAt ?? 0));
          deliveredTo.sort(
            (a, b) => (b.deliveredAt ?? 0).compareTo(a.deliveredAt ?? 0),
          );

          return MessageInfoData(
            readBy: readBy,
            deliveredTo: deliveredTo,
            remaining: remaining,
            isGroup: true,
            totalParticipants: processedUserIds.length,
          );
        } else {
          String? recipientId;
          for (final s in statusRows) {
            if (s.userId != currentUserId) {
              recipientId = s.userId;
              break;
            }
          }
          if (recipientId == null) {
            final pRows =
                await (db.select(db.chatParticipants)..where(
                      (tbl) =>
                          tbl.chatId.equals(effectiveChatId) &
                          tbl.userId.equals(currentUserId ?? '').not(),
                    ))
                    .get();
            if (pRows.isNotEmpty) {
              recipientId = pRows.first.userId;
            } else if (effectiveChatId.startsWith('local_')) {
              recipientId = effectiveChatId.replaceFirst('local_', '');
            }
          }

          final List<MessageRecipientStatus> readBy = [];
          final List<MessageRecipientStatus> deliveredTo = [];
          final List<MessageRecipientStatus> remaining = [];

          if (recipientId != null) {
            final userRow =
                await (db.select(db.usersTable)
                      ..where((tbl) => tbl.userId.equals(recipientId!)))
                    .getSingleOrNull();
            final mediaRow =
                await (db.select(db.mediaTable)
                      ..where((tbl) => tbl.actorId.equals(recipientId!)))
                    .getSingleOrNull();
            final s = statusByUserId[recipientId];

            final recipient = MessageRecipientStatus(
              userId: recipientId,
              name: userRow?.name ?? recipientId,
              profilePicUrl: mediaRow?.location ?? mediaRow?.url,
              status: s?.status ?? 'sending',
              deliveredAt: s?.deliveredAt,
              readAt: s?.readAt,
            );

            if (s?.readAt != null || s?.status == 'read') {
              readBy.add(recipient);
            }
            if (s?.deliveredAt != null || s?.status == 'delivered') {
              deliveredTo.add(recipient);
            }
            if (readBy.isEmpty && deliveredTo.isEmpty) {
              remaining.add(recipient);
            }
          }

          return MessageInfoData(
            readBy: readBy,
            deliveredTo: deliveredTo,
            remaining: remaining,
            isGroup: false,
            totalParticipants: 1,
          );
        }
      });
    });

class MessageStatusTableProvider extends Notifier {
  @override
  build() {}

  Future<void> bulkCreateMessageStatus(
    List<MessageStatus> statuses,
    String messageId,
  ) async {
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
