import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/modal/shared_media_item_model.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/chat_list_table_provider.dart';

final sharedMediaProvider =
    StreamProvider.autoDispose.family<List<SharedMediaItemModel>, String>((
      ref,
      targetId,
    ) async* {
      final db = ref.watch(databaseProvider);

      // Resolve actual chatId if targetId was a userId
      String chatId = targetId;
      final directChatId = await ref
          .read(chatListTableProvider.notifier)
          .findDirectChatIdWithUser(targetId);
      if (directChatId != null && directChatId.isNotEmpty) {
        chatId = directChatId;
      }

      final query =
          (db.select(db.messages)
                ..where(
                  (tbl) =>
                      tbl.chatId.equals(chatId) & tbl.isDeleted.equals(false),
                )
                ..orderBy([
                  (tbl) => OrderingTerm(
                    expression: tbl.createdAt,
                    mode: OrderingMode.desc,
                  ),
                ]))
              .join([
                innerJoin(
                  db.mediaTable,
                  db.mediaTable.actorId.equalsExp(db.messages.id) |
                      db.mediaTable.actorId.equalsExp(db.messages.serverId),
                ),
                leftOuterJoin(
                  db.usersTable,
                  db.usersTable.userId.equalsExp(db.messages.senderId),
                ),
              ]);

      yield* query.watch().map((rows) {
        final seenIds = <int>{};
        final items = <SharedMediaItemModel>[];

        for (final row in rows) {
          final mediaRow = row.readTable(db.mediaTable);
          if (!seenIds.add(mediaRow.id)) continue;

          final messageRow = row.readTable(db.messages);
          final userRow = row.readTableOrNull(db.usersTable);

          items.add(
            SharedMediaItemModel(
              id: mediaRow.id,
              messageId:
                  (messageRow.serverId != null &&
                          messageRow.serverId!.isNotEmpty)
                      ? messageRow.serverId!
                      : messageRow.id,
              chatId: messageRow.chatId,
              senderId: messageRow.senderId,
              senderName:
                  userRow != null && userRow.name.isNotEmpty
                      ? userRow.name
                      : messageRow.senderId,
              type: mediaRow.Type ?? "",
              name: mediaRow.name ?? "",
              key: mediaRow.key ?? "",
              location: mediaRow.location,
              url: mediaRow.url,
              contentType: mediaRow.contentType,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                mediaRow.createdAt > 0
                    ? mediaRow.createdAt
                    : messageRow.createdAt,
              ),
            ),
          );
        }

        return items;
      });
    });
