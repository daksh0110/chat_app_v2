import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:drift/drift.dart';

final chatMessagesProvider = StreamProvider.family<List<Message>, int>((
  ref,
  chatId,
) {
  final database = ref.watch(databaseProvider);

  return (database.select(database.messages)
        ..where((tbl) => tbl.chatId.equals(chatId))
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
      .watch();
});

final chatIdProvider = FutureProvider.family<int?, String>((
  ref,
  receiverId,
) async {
  final db = ref.read(databaseProvider);

  final chat = await db.managers.chatListTable
      .filter((f) => f.userId(receiverId))
      .getSingleOrNull();

  return chat?.id;
});
