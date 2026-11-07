import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/chat_settings_table_provider.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/screens/home/chat_list_item.dart';
import 'package:drift/drift.dart' hide Column;

class ArchivedChatsScreen extends ConsumerStatefulWidget {
  const ArchivedChatsScreen({super.key});

  @override
  ConsumerState<ArchivedChatsScreen> createState() =>
      _ArchivedChatsScreenState();
}

class _ArchivedChatsScreenState extends ConsumerState<ArchivedChatsScreen> {
  @override
  void dispose() {
    Future(() {
      ref.read(selectedChatListProvider.notifier).clearList();
    });
    super.dispose();
  }

  void _unarchiveSelected(List<String> selectedList) async {
    for (final chatId in selectedList) {
      await ref
          .read(chatSettingsTableProvider.notifier)
          .toggleArchive(chatId: chatId, isArchived: false);
    }
    ref.read(selectedChatListProvider.notifier).clearList();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedList.length == 1
                ? 'Chat unarchived'
                : '${selectedList.length} chats unarchived',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteSelected(List<String> selectedList) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: DefaultColorSheet.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Delete selected chats?",
          style: TextStyle(color: DefaultColorSheet.textPrimary(context)),
        ),
        content: Text(
          "These chats and their messages will be deleted from this device.",
          style: TextStyle(color: DefaultColorSheet.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final db = ref.read(databaseProvider);
    await db.managers.messages
        .filter((f) => f.chatId.isIn(selectedList))
        .delete();
    await db.managers.chatListTable
        .filter((f) => f.chatId.isIn(selectedList))
        .update((o) => o(isDeleted: const Value(true)));
    ref.read(selectedChatListProvider.notifier).clearList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedList = ref.watch(selectedChatListProvider);
    final selectedNotifier = ref.read(selectedChatListProvider.notifier);
    final isSelecting = selectedList.isNotEmpty;

    final archivedChatsAsync = ref.watch(archivedChatListProvider);
    final isDark = DefaultColorSheet.isDark(context);
    final iconColor = DefaultColorSheet.appBarIcon(context);
    final textPrimary = DefaultColorSheet.textPrimary(context);
    final textSecondary = DefaultColorSheet.textSecondary(context);

    return Scaffold(
      backgroundColor: DefaultColorSheet.scaffoldBg(context),
      appBar: AppBar(
        backgroundColor: DefaultColorSheet.appBarBg(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: isSelecting
            ? IconButton(
                icon: Icon(Icons.close, color: iconColor),
                onPressed: () => selectedNotifier.clearList(),
              )
            : IconButton(
                icon: Icon(Icons.arrow_back, color: iconColor),
                onPressed: () => Navigator.maybePop(context),
              ),
        title: Text(
          isSelecting
              ? '${selectedList.length} selected'
              : 'Archived chats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        actions: isSelecting
            ? [
                IconButton(
                  icon: const Icon(
                    LucideIcons.archiveRestore,
                    color: DefaultColorSheet.accentGreen,
                    size: 22,
                  ),
                  tooltip: 'Unarchive',
                  onPressed: () => _unarchiveSelected(selectedList),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.trash2,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  tooltip: 'Delete',
                  onPressed: () => _deleteSelected(selectedList),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: archivedChatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DefaultColorSheet.accentGreen
                          .withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.archive,
                      size: 48,
                      color: DefaultColorSheet.accentGreen,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No archived chats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Chats you archive will stay stored here without cluttering your main chat list.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return PrimaryContainer(
            children: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        size: 15,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'These chats stay archived when new messages arrive.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),
                Expanded(
                  child: ListView.separated(
                    itemCount: chats.length,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final isSelected = selectedList.contains(chat.chatId);

                      return ChatListItem(
                        chat: chat,
                        isSelected: isSelected,
                        onTap: () {
                          if (isSelecting) {
                            selectedNotifier.modifyList(chat.chatId);
                          } else {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.message,
                              arguments: MessageScreenArguments(
                                chatId: chat.chatId,
                                name: chat.name ?? '',
                                profilePicUrl: chat.profilePicUrl,
                                isGroupChat: chat.type,
                                receiverId: chat.receiverId ?? '',
                              ),
                            );
                          }
                        },
                        onHold: () {
                          selectedNotifier.modifyList(chat.chatId);
                        },
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 1),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: TextStyle(color: textSecondary),
          ),
        ),
      ),
    );
  }
}
