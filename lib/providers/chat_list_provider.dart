import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';

final chatListProvider = StreamProvider<List<ChatListModal>>((ref) {
  final db = ref.watch(databaseProvider);
  final user = ref.watch(settingsUserProvider);
  final query = db.select(db.chatListTable).join([
    leftOuterJoin(
      db.chatParticipants,
      db.chatParticipants.chatId.equalsExp(db.chatListTable.chatId) &
          db.chatListTable.type.equals('DIRECT'),
    ),
    leftOuterJoin(
      db.mediaTable,
      (db.chatListTable.type.equals('DIRECT') &
              db.mediaTable.actorId.equalsExp(db.chatParticipants.userId)) |
          (db.chatListTable.type.equals('DIRECT').not() &
              db.mediaTable.actorId.equalsExp(db.chatListTable.chatId)),
    ),
  ]);

  return query.watch().map((rows) {
    return rows
        .where((row) {
          final chat = row.readTable(db.chatListTable);
          final participant = row.readTableOrNull(db.chatParticipants);

          return chat.type != "DIRECT" || participant?.userId != user?.id;
        })
        .map((row) {
          final chat = row.readTable(db.chatListTable);
          final media = row.readTableOrNull(db.mediaTable);

          return ChatListModal(
            chatId: chat.chatId,
            name: chat.name,
            lastMessage: chat.lastMessage ?? "",
            lastMessageTime: chat.lastMessageTime != null
                ? DateFormat("HH:mm").format(
                    DateTime.fromMillisecondsSinceEpoch(chat.lastMessageTime!),
                  )
                : "",
            unReadCount: chat.unReadCount,
            type: chat.type,
            id: chat.id.toString(),
            profilePicUrl: chat.type == "DIRECT"
                ? (media?.location ?? media?.url)
                : media?.location,
          );
        })
        .toList();
  });
});

final chatListControllerProvider = Provider<ChatListController>((ref) {
  return ChatListController(ref);
});

class ChatListController {
  ChatListController(this._ref);
  final Ref _ref;

  String? activeChatId;

  Future<void> setActiveChatId(String? otherUserId) async {
    activeChatId = otherUserId;
    if (otherUserId == null) return;
    await markChatAsRead(otherUserId);
  }

  Future<void> markChatAsRead(String chatId) async {
    final db = _ref.read(databaseProvider);
    final me = _ref.read(settingsUserProvider);
    if (me == null) return;

    await (db.update(db.chatListTable)..where((t) => t.chatId.equals(chatId)))
        .write(const ChatListTableCompanion(unReadCount: Value(0)));

    await (db.update(
      db.messages,
    )..where((m) => m.chatId.equals(chatId) & m.isRead.equals(false))).write(
      const MessagesCompanion(
        isRead: Value(true),
        messageStatus: Value("read"),
      ),
    );
  }
}

final selectedChatListProvider =
    NotifierProvider<SelectedChatListNotifier, List<String>>(
      () => SelectedChatListNotifier(),
    );

class SelectedChatListNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  void modifyList(String item) {
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
