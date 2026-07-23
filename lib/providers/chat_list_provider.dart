import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';

final chatListProvider = StreamProvider<List<ChatListModal>>((ref) {
  final db = ref.watch(databaseProvider);
  final currentUserId = ref.watch(userPreferenceTableProvider).value;

  if (currentUserId == null) return Stream.value([]);

  final query = db.select(db.chatListTable)
    ..where((t) => t.isDeleted.equals(false))
    ..orderBy([
      (t) =>
          OrderingTerm(expression: t.lastMessageTime, mode: OrderingMode.desc),
    ]);

  final joinedQuery = query.join([
    leftOuterJoin(
      db.chatParticipants,
      db.chatParticipants.chatId.equalsExp(db.chatListTable.chatId) &
          db.chatListTable.type.equals('DIRECT') &
          db.chatParticipants.userId.isNotValue(currentUserId),
    ),
    leftOuterJoin(
      db.usersTable,
      db.usersTable.userId.equalsExp(db.chatParticipants.userId),
    ),
    leftOuterJoin(
      db.groupListTable,
      db.groupListTable.chatId.equalsExp(db.chatListTable.chatId) &
          db.chatListTable.type.equals('GROUP'),
    ),
    // D. Dynamic Media lookup
    leftOuterJoin(
      db.mediaTable,
      (db.chatListTable.type.equals('DIRECT') &
              db.mediaTable.actorId.equalsExp(db.chatParticipants.userId)) |
          (db.chatListTable.type.equals('GROUP') &
              db.mediaTable.actorId.equalsExp(db.chatListTable.chatId)),
    ),
  ]);
  return joinedQuery.watch().map((rows) {
    final List<ChatListModal> list = [];
    final seenChatIds =
        <String>{}; // Guards against duplication from media rows

    for (final row in rows) {
      final chat = row.readTable(db.chatListTable);

      if (seenChatIds.contains(chat.chatId)) continue;

      final userProfile = row.readTableOrNull(db.usersTable);
      final groupProfile = row.readTableOrNull(db.groupListTable);
      final media = row.readTableOrNull(db.mediaTable);

      String resolvedName = "Unknown Chat";
      if (chat.type == "DIRECT" && userProfile != null) {
        resolvedName = userProfile.name;
      } else if (chat.type == "GROUP" && groupProfile != null) {
        resolvedName = groupProfile.name;
      }

      String? profilePic;
      if (chat.type == "DIRECT") {
        profilePic = media?.location ?? media?.url;
      } else {
        profilePic = media?.location;
      }

      list.add(
        ChatListModal(
          chatId: chat.chatId,
          name: resolvedName,
          lastMessage: chat.lastMessage ?? "",
          lastMessageTime: chat.lastMessageTime != null
              ? DateFormat("HH:mm").format(
                  DateTime.fromMillisecondsSinceEpoch(chat.lastMessageTime!),
                )
              : "",
          unReadCount: chat.unReadCount,
          type: chat.type,
          id: chat.chatId, // Using chatId as the unique identifier
          profilePicUrl: profilePic,
        ),
      );

      seenChatIds.add(chat.chatId);
    }

    return list;
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
    final me = _ref.watch(userPreferenceTableProvider).value;
    if (me == null) return;

    await (db.update(db.chatListTable)..where((t) => t.chatId.equals(chatId)))
        .write(const ChatListTableCompanion(unReadCount: Value(0)));

    await (db.update(db.messages)
          ..where((m) => m.chatId.equals(chatId) & m.isRead.equals(false)))
        .write(const MessagesCompanion(isRead: Value(true)));
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
