import 'dart:ffi';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';

final chatListProvider = StreamProvider<List<ChatListModal>>((ref) {
  final db = ref.watch(databaseProvider);

  return (db.select(db.chatListTable)
        ..orderBy([(t) => OrderingTerm.desc(t.lastMessageTime)]))
      .watch()
      .map((rows) => rows.map(ChatListModal.fromDrift).toList());
});

final chatListControllerProvider = Provider<ChatListController>((ref) {
  return ChatListController(ref);
});

class ChatListController {
  ChatListController(this._ref);
  final Ref _ref;

  String? activeChatUserId;

  Future<void> setActiveChatUserId(String? otherUserId) async {
    activeChatUserId = otherUserId;
    if (otherUserId == null) return;
    await markChatAsRead(otherUserId);
  }

  Future<void> markChatAsRead(String otherUserId) async {
    final db = _ref.read(databaseProvider);
    final me = _ref.read(settingsUserProvider);
    if (me == null) return;

    final chat = await (db.select(
      db.chatListTable,
    )..where((t) => t.userId.equals(otherUserId))).getSingleOrNull();

    if (chat == null) return;

    await (db.update(db.chatListTable)..where((t) => t.id.equals(chat.id)))
        .write(const ChatListTableCompanion(unReadCount: Value(0)));

    await (db.update(db.messages)
          ..where((m) => m.chatId.equals(chat.chatId) & m.isRead.equals(false)))
        .write(const MessagesCompanion(isRead: Value(true)));
  }
}

final selectedChatListProvider =
    NotifierProvider<SelectedChatListNotifier, List<int>>(
      () => SelectedChatListNotifier(),
    );

class SelectedChatListNotifier extends Notifier<List<int>> {
  @override
  List<int> build() {
    return [];
  }

  void modifyList(int item) {
    if (state.contains(item)) {
      state = state.where((i) => i != item).toList();
    } else {
      state = [...state, item];
    }
  }

  void clearList() {
    state = [];
  }
}
