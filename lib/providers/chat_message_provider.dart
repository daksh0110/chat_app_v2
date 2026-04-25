import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:drift/drift.dart';

final chatMessagesProvider =
    StreamProvider.family<List<Message>, ({String chatId, String receiverId})>((
      ref,
      args,
    ) {
      final db = ref.watch(databaseProvider);
      debugPrint("real Chat Id ${args.chatId}");
      debugPrint("receiver Chat Id ${args.receiverId}");
      final localChatId = args.chatId.isNotEmpty
          ? args.chatId
          : "local_${args.receiverId}";

      return (db.select(db.messages)
            ..where(
              (tbl) =>
                  tbl.chatId.equals(args.chatId) |
                  tbl.chatId.equals(localChatId),
            )
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
          .watch();
    });
