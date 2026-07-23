import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/screens/createGroup/create_group_response.dart';
import 'package:my_app/providers/database_provider.dart';

final chatParticipantsTableProvider =
    NotifierProvider<ChatParticipantsTable, void>(
      () => ChatParticipantsTable(),
    );

class ChatParticipantsTable extends Notifier {
  @override
  build() {}

  Future<void> bulkInsertParticipants(List<Participant> participants) async {
    final db = ref.read(databaseProvider);
    await db.batch((batch) {
      batch.insertAll(
        db.chatParticipants,
        participants.map(
          (participant) => ChatParticipantsCompanion.insert(
            chatId: participant.chatId,
            userId: participant.userId,
            role: Value(participant.role),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> updateParticipantsChatId(String oldChatId, String chatId) async {
    final db = ref.read(databaseProvider);

    await (db.update(db.chatParticipants)
          ..where((tbl) => tbl.chatId.equals(oldChatId)))
        .write(ChatParticipantsCompanion(chatId: Value(chatId)));
  }
}
