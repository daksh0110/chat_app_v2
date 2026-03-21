import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:drift/drift.dart';

final chatMessagesProvider =
    StreamProvider.family<List<Message>, ({String? chatId, String receiverId})>(
      (ref, args) {
        final database = ref.watch(databaseProvider);

        final localChatId = "local_${args.receiverId}";
        final realChatId = args.chatId;

        final activeChatId = realChatId ?? localChatId;

        return (database.select(database.messages)
              ..where((tbl) => tbl.chatId.equals(activeChatId))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
            .watch();
      },
    );

final chatIdProvider = StreamProvider.family<String?, String?>((
  ref,
  receiverId,
) {
  final db = ref.watch(databaseProvider);

  return db.managers.chatListTable
      .filter((f) => f.userId(receiverId))
      .watchSingleOrNull()
      .map((chat) => chat?.chatId);
});
