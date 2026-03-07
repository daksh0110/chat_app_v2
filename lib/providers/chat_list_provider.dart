import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/providers/database_provider.dart';

final chatListProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);

  return db
      .select(db.chatListTable)
      .watch()
      .map((rows) => rows.map(ChatListModal.fromDrift).toList());
});
