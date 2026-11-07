import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/modal/screens/message/message_item_model.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ForwardMessageDialog extends ConsumerStatefulWidget {
  final List<MessageItemModel> messages;

  const ForwardMessageDialog({
    super.key,
    required this.messages,
  });

  static Future<List<ChatListModal>?> show(
    BuildContext context, {
    required List<MessageItemModel> messages,
  }) {
    return showModalBottomSheet<List<ChatListModal>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ForwardMessageDialog(messages: messages),
    );
  }

  @override
  ConsumerState<ForwardMessageDialog> createState() =>
      _ForwardMessageDialogState();
}

class _ForwardMessageDialogState extends ConsumerState<ForwardMessageDialog> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedChatIds = {};
  final Map<String, ChatListModal> _selectedChatsMap = {};
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleChat(ChatListModal chat) {
    setState(() {
      if (_selectedChatIds.contains(chat.chatId)) {
        _selectedChatIds.remove(chat.chatId);
        _selectedChatsMap.remove(chat.chatId);
      } else {
        _selectedChatIds.add(chat.chatId);
        _selectedChatsMap[chat.chatId] = chat;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatListAsync = ref.watch(chatListProvider);
    final cardBg = DefaultColorSheet.surfaceBg(context);
    final textPrimary = DefaultColorSheet.textPrimary(context);
    final textSecondary = DefaultColorSheet.textSecondary(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: DefaultColorSheet.grey400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryText(
                        'Forward to...',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      const SizedBox(height: 2),
                      PrimaryText(
                        '${widget.messages.length} ${widget.messages.length == 1 ? "message" : "messages"} selected',
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: TextStyle(fontSize: 14, color: textSecondary),
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 18,
                  color: textSecondary,
                ),
                filled: true,
                fillColor: DefaultColorSheet.inputFieldBg(context),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Chat list
          Expanded(
            child: chatListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: PrimaryText(
                  'Error loading chats: $err',
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
              data: (chats) {
                final filteredChats = chats.where((c) {
                  if (_searchQuery.isEmpty) return true;
                  final name = c.name?.toLowerCase() ?? '';
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredChats.isEmpty) {
                  return Center(
                    child: PrimaryText(
                      _searchQuery.isEmpty
                          ? 'No chats found'
                          : 'No matching chats found',
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filteredChats.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 68,
                    color: DefaultColorSheet.divider(context),
                  ),
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    final isSelected = _selectedChatIds.contains(chat.chatId);
                    final isProfilePicValid = chat.profilePicUrl != null &&
                        File(chat.profilePicUrl!).existsSync();

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Stack(
                        children: [
                          ClipOval(
                            child: isProfilePicValid
                                ? Image.file(
                                    File(chat.profilePicUrl!),
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF075E54),
                                      shape: BoxShape.circle,
                                    ),
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    child: PrimaryText(
                                      (chat.name?.isNotEmpty == true
                                          ? chat.name![0].toUpperCase()
                                          : "?"),
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          if (isSelected)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: DefaultColorSheet.green500,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: PrimaryText(
                        chat.name ?? 'Chat',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                      subtitle: PrimaryText(
                        chat.type == 'GROUP' ? 'Group' : (chat.bio ?? 'Direct Chat'),
                        fontSize: 12,
                        color: textSecondary,
                        maxLines: 1,
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        activeColor: DefaultColorSheet.green500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (_) => _toggleChat(chat),
                      ),
                      onTap: () => _toggleChat(chat),
                    );
                  },
                );
              },
            ),
          ),

          // Forward action button bar
          if (_selectedChatIds.isNotEmpty)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border(
                    top: BorderSide(
                      color: DefaultColorSheet.divider(context),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryText(
                        '${_selectedChatIds.length} ${_selectedChatIds.length == 1 ? "chat" : "chats"} selected',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DefaultColorSheet.green500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(LucideIcons.sendHorizontal, size: 18),
                      label: const Text(
                        'Forward',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(_selectedChatsMap.values.toList());
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

