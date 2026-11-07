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
    leftOuterJoin(
      db.mediaTable,
      (db.chatListTable.type.equals('DIRECT') &
              db.mediaTable.actorId.equalsExp(db.chatParticipants.userId)) |
          (db.chatListTable.type.equals('GROUP') &
              db.mediaTable.actorId.equalsExp(db.chatListTable.chatId)),
    ),
    leftOuterJoin(
      db.chatSettingsTable,
      db.chatSettingsTable.chatId.equalsExp(db.chatListTable.chatId),
    ),
  ]);

  return joinedQuery.watch().map((rows) {
    final List<ChatListModal> list = [];
    final seenChatIds = <String>{};

    for (final row in rows) {
      final chat = row.readTable(db.chatListTable);

      if (seenChatIds.contains(chat.chatId)) continue;

      final userProfile = row.readTableOrNull(db.usersTable);
      final groupProfile = row.readTableOrNull(db.groupListTable);
      final media = row.readTableOrNull(db.mediaTable);
      final settings = row.readTableOrNull(db.chatSettingsTable);

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

      final isPinned = settings?.isPinned ?? false;
      final isArchived = settings?.isArchived ?? false;
      final isMuted =
          settings != null &&
          settings.isMuted &&
          (settings.mutedUntil == null ||
              DateTime.now().millisecondsSinceEpoch < settings.mutedUntil!);

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
          id: chat.chatId,
          profilePicUrl: profilePic,
          receiverId: userProfile?.userId ??
              row.readTableOrNull(db.chatParticipants)?.userId,
          isPinned: isPinned,
          isArchived: isArchived,
          isMuted: isMuted,
        ),
      );

      seenChatIds.add(chat.chatId);
    }

    final visibleList = list.where((c) => !c.isArchived).toList();

    visibleList.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    return visibleList;
  });
});

final archivedChatListProvider = StreamProvider<List<ChatListModal>>((ref) {
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
    leftOuterJoin(
      db.mediaTable,
      (db.chatListTable.type.equals('DIRECT') &
              db.mediaTable.actorId.equalsExp(db.chatParticipants.userId)) |
          (db.chatListTable.type.equals('GROUP') &
              db.mediaTable.actorId.equalsExp(db.chatListTable.chatId)),
    ),
    innerJoin(
      db.chatSettingsTable,
      db.chatSettingsTable.chatId.equalsExp(db.chatListTable.chatId) &
          db.chatSettingsTable.isArchived.equals(true),
    ),
  ]);

  return joinedQuery.watch().map((rows) {
    final List<ChatListModal> list = [];
    final seenChatIds = <String>{};

    for (final row in rows) {
      final chat = row.readTable(db.chatListTable);
      if (seenChatIds.contains(chat.chatId)) continue;

      final userProfile = row.readTableOrNull(db.usersTable);
      final groupProfile = row.readTableOrNull(db.groupListTable);
      final media = row.readTableOrNull(db.mediaTable);
      final settings = row.readTableOrNull(db.chatSettingsTable);

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
          id: chat.chatId,
          profilePicUrl: profilePic,
          receiverId: userProfile?.userId ??
              row.readTableOrNull(db.chatParticipants)?.userId,
          isPinned: settings?.isPinned ?? false,
          isArchived: true,
          isMuted: settings?.isMuted ?? false,
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
        .write(ChatListTableCompanion(unReadCount: const Value(0)));

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
