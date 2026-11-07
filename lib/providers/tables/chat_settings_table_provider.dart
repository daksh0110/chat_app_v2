import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/chat_settings_modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/socket_provider.dart';

final chatSettingsTableProvider =
    NotifierProvider<ChatSettingsTableProvider, void>(
      ChatSettingsTableProvider.new,
    );

final chatSettingsStreamProvider =
    StreamProvider.family<ChatSettingsModal, String>((ref, chatId) {
      return ref
          .watch(chatSettingsTableProvider.notifier)
          .watchChatSettings(chatId);
    });

class ChatSettingsTableProvider extends Notifier<void> {
  @override
  void build() {}

  Stream<ChatSettingsModal> watchChatSettings(String chatId) {
    final db = ref.watch(databaseProvider);
    return (db.select(db.chatSettingsTable)
          ..where((tbl) => tbl.chatId.equals(chatId)))
        .watchSingleOrNull()
        .map((row) {
          if (row == null) {
            return ChatSettingsModal(chatId: chatId);
          }
          return _mapRowToModal(row);
        });
  }

  Future<ChatSettingsModal> getChatSettings(String chatId) async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(
      db.chatSettingsTable,
    )..where((tbl) => tbl.chatId.equals(chatId))).getSingleOrNull();

    if (row == null) {
      return ChatSettingsModal(chatId: chatId);
    }
    return _mapRowToModal(row);
  }

  ChatSettingsModal _mapRowToModal(ChatSettingsTableData row) {
    return ChatSettingsModal(
      chatId: row.chatId,
      notifications: ChatNotificationSettings(
        isMuted: row.isMuted,
        mutedUntil: row.mutedUntil,
        notificationSound: row.notificationSound,
      ),
      appearance: ChatAppearanceSettings(wallpaper: row.wallpaper),
      management: ChatManagementSettings(
        isPinned: row.isPinned,
        pinnedAt: row.pinnedAt,
        isArchived: row.isArchived,
        archivedAt: row.archivedAt,
      ),
      privacy: ChatPrivacySettings(
        disappearingDuration: row.disappearingDuration,
      ),
      storage: ChatStorageSettings(mediaAutoDownload: row.mediaAutoDownload),
    );
  }

  Future<void> updateMute({
    required String chatId,
    required bool isMuted,
    int? mutedUntil,
  }) async {
    final db = ref.read(databaseProvider);
    await db
        .into(db.chatSettingsTable)
        .insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            chatId: Value(chatId),
            isMuted: Value(isMuted),
            mutedUntil: Value(isMuted ? mutedUntil : null),
          ),
        );

    _syncToBackend(chatId, {
      'notifications': {
        'is_muted': isMuted,
        'muted_until': isMuted && mutedUntil != null
            ? DateTime.fromMillisecondsSinceEpoch(mutedUntil).toIso8601String()
            : null,
      },
    });
  }

  // --- 2. Notification Sound (Local Only) ---
  Future<void> updateNotificationSound({
    required String chatId,
    required String sound,
  }) async {
    final db = ref.read(databaseProvider);
    await db
        .into(db.chatSettingsTable)
        .insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            chatId: Value(chatId),
            notificationSound: Value(sound),
          ),
        );
  }

  Future<void> updateWallpaper({
    required String chatId,
    String? wallpaper,
  }) async {
    final db = ref.read(databaseProvider);
    await db
        .into(db.chatSettingsTable)
        .insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            chatId: Value(chatId),
            wallpaper: Value(wallpaper),
          ),
        );
  }

  Future<void> togglePin({required String chatId, bool? isPinned}) async {
    final current = await getChatSettings(chatId);
    final targetState = isPinned ?? !current.isPinned;
    final now = DateTime.now().millisecondsSinceEpoch;

    final db = ref.read(databaseProvider);
    await db
        .into(db.chatSettingsTable)
        .insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            chatId: Value(chatId),
            isPinned: Value(targetState),
            pinnedAt: Value(targetState ? now : null),
          ),
        );

    _syncToBackend(chatId, {
      'chat_management': {'is_pinned': targetState},
    });
  }

  Future<void> toggleArchive({required String chatId, bool? isArchived}) async {
    final current = await getChatSettings(chatId);
    final targetState = isArchived ?? !current.isArchived;
    final now = DateTime.now().millisecondsSinceEpoch;

    final db = ref.read(databaseProvider);
    await db
        .into(db.chatSettingsTable)
        .insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            chatId: Value(chatId),
            isArchived: Value(targetState),
            archivedAt: Value(targetState ? now : null),
          ),
        );

    _syncToBackend(chatId, {
      'chat_management': {'is_archived': targetState},
    });
  }

  Future<void> updateDisappearingDuration({
    required String chatId,
    required int durationSeconds,
  }) async {
    final db = ref.read(databaseProvider);
    await db
        .into(db.chatSettingsTable)
        .insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            chatId: Value(chatId),
            disappearingDuration: Value(durationSeconds),
          ),
        );

    try {
      ref
          .read(socketProvider)
          .updateDisappearingMessages(
            chatId: chatId,
            duration: durationSeconds,
          );
    } catch (_) {}
  }

  Future<void> updateMediaAutoDownload({
    required String chatId,
    required String setting,
  }) async {
    final db = ref.read(databaseProvider);
    await db
        .into(db.chatSettingsTable)
        .insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            chatId: Value(chatId),
            mediaAutoDownload: Value(setting),
          ),
        );
  }

  Future<void> clearChatHistory({required String chatId}) async {
    final db = ref.read(databaseProvider);

    await (db.delete(db.messages)..where((t) => t.chatId.equals(chatId))).go();

    await (db.update(
      db.chatListTable,
    )..where((t) => t.chatId.equals(chatId))).write(
      const ChatListTableCompanion(
        lastMessage: Value(""),
        unReadCount: Value(0),
      ),
    );
  }

  Future<void> deleteConversation({required String chatId}) async {
    final db = ref.read(databaseProvider);

    await (db.delete(db.messages)..where((t) => t.chatId.equals(chatId))).go();

    await (db.update(
      db.chatListTable,
    )..where((t) => t.chatId.equals(chatId))).write(
      const ChatListTableCompanion(
        isDeleted: Value(true),
        lastMessage: Value(""),
        unReadCount: Value(0),
      ),
    );
  }

  Future<void> upsertRemoteSettings(ChatSettingsModal settings) async {
    final db = ref.read(databaseProvider);
    await db
        .into(db.chatSettingsTable)
        .insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            chatId: Value(settings.chatId),
            isMuted: Value(settings.isMuted),
            mutedUntil: Value(settings.mutedUntil),
            isPinned: Value(settings.isPinned),
            pinnedAt: Value(settings.pinnedAt),
            isArchived: Value(settings.isArchived),
            archivedAt: Value(settings.archivedAt),
            disappearingDuration: Value(settings.disappearingDuration),
          ),
        );
  }

  void _syncToBackend(String chatId, Map<String, dynamic> updates) {
    try {
      ref
          .read(socketProvider)
          .updateChatSettings(chatId: chatId, updates: updates);
    } catch (_) {}
  }
}
