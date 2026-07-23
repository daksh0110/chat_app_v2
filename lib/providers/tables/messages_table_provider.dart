import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/screens/message/message_body_request.dart';
import 'package:my_app/providers/database_provider.dart';

final messagesTableProvider = NotifierProvider<MessagesTableProvider, void>(
  MessagesTableProvider.new,
);

class MessagesTableProvider extends Notifier {
  @override
  build() {}

  Future<void> createTempMessage(MessageBodyRequest messageBody) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    await db
        .into(db.messages)
        .insert(
          MessagesCompanion(
            chatId: Value(messageBody.chatId ?? ""),
            createdAt: Value(now),
            id: Value(messageBody.tempId ?? ""),
            isRead: Value(messageBody.isRead),
            message: Value(messageBody.message ?? ""),
            senderId: Value(messageBody.senderId ?? ""),
          ),
        );
  }

  Future<void> updateTempMessage(
    MessageBodyRequest messageBody,
    String newId,
  ) async {
    final db = ref.read(databaseProvider);

    final existingTempMessage =
        await (db.select(db.messages)
              ..where((tbl) => tbl.id.equals(messageBody.tempId ?? "")))
            .getSingleOrNull();
    if (existingTempMessage != null) {
      await (db.update(
        db.messages,
      )..where((tbl) => tbl.id.equals(messageBody.tempId ?? ""))).write(
        MessagesCompanion(
          id: Value(newId),
          serverId: Value(newId),
          chatId: Value(messageBody.chatId ?? existingTempMessage.chatId),
        ),
      );
    }
  }

  Future<void> createOrUpdateMessage(MessageBodyRequest messageRequest) async {
    final db = ref.read(databaseProvider);
    try {
      await db
          .into(db.messages)
          .insertOnConflictUpdate(
            MessagesCompanion(
              chatId: Value(messageRequest.chatId ?? ""),
              id: Value(messageRequest.messageId ?? ""),
              createdAt: Value(messageRequest.createdAt),
              isRead: Value(messageRequest.isRead),
              message: Value(messageRequest.message ?? ""),
              senderId: Value(messageRequest.senderId ?? ""),
              serverCreatedAt: Value(messageRequest.serverCreatedAt),
            ),
          );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
