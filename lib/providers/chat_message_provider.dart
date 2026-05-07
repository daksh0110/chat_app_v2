import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:drift/drift.dart';

class MessageWithSender {
  final Message message;
  final ChatParticipant participant;
  final bool isGroupChat;

  MessageWithSender({
    required this.message,
    required this.participant,
    this.isGroupChat = false,
  });
}

final chatMessagesProvider =
    StreamProvider.family<
      List<MessageWithSender>,
      ({String chatId, String receiverId})
    >((ref, args) {
      final db = ref.watch(databaseProvider);
      debugPrint("real Chat Id ${args.chatId}");
      debugPrint("receiver Chat Id ${args.receiverId}");
      final localChatId = args.chatId.isNotEmpty
          ? args.chatId
          : "local_${args.receiverId}";

      final query = db.select(db.messages).join([
        innerJoin(
          db.chatParticipants,
          db.chatParticipants.userId.equalsExp(db.messages.senderId) &
              db.chatParticipants.chatId.equalsExp(db.messages.chatId),
        ),
      ]);

      query.where(
        db.messages.chatId.equals(args.chatId) |
            db.messages.chatId.equals(localChatId),
      );

      query.orderBy([OrderingTerm.asc(db.messages.createdAt)]);
      return query.watch().map((rows) {
        return rows.map((row) {
          return MessageWithSender(
            message: row.readTable(db.messages),
            participant: row.readTable(db.chatParticipants),
            isGroupChat: false,
          );
        }).toList();
      });
    });
