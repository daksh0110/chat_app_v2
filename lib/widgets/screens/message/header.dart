import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/screens/search/user_profile_arguments.dart';
import 'package:my_app/providers/tables/chat_settings_table_provider.dart';
import 'package:my_app/screens/chat_settings_screen.dart';
import 'package:my_app/widgets/screens/search/search_group_item.dart';

class Header extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const Header({
    super.key,
    required this.name,
    required this.id,
    required this.isOnline,
    this.profilePicUrl,
    this.isGroupChat = false,
    this.subtitle,
  });

  final String name;
  final String id;
  final bool isOnline;
  final bool isGroupChat;
  final String? profilePicUrl;
  final String? subtitle;

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight);
  }

  @override
  ConsumerState<Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<Header> {
  double getToolbarHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenHeight < 600) {
      return 48;
    } else if (screenHeight < 750) {
      return 52;
    } else {
      return 56;
    }
  }

  @override
  Widget build(BuildContext context) {
    final toolbarHeight = getToolbarHeight(context);
    final iconColor = DefaultColorSheet.appBarIcon(context);

    return AppBar(
      toolbarHeight: toolbarHeight,
      shadowColor: const Color(0x05111222),
      backgroundColor: DefaultColorSheet.appBarBg(context),
      iconTheme: IconThemeData(color: iconColor),
      scrolledUnderElevation: 0.0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.userProfile,
            arguments: UserProfileArguments(
              id: widget.id,
              isGroupChat: widget.isGroupChat,
              name: widget.name,
              profilePicUrl: widget.profilePicUrl,
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: SearchGroupItem(
          height: toolbarHeight - 8,
          chatBubbleSize: toolbarHeight - 12,
          needActiveIndicator: widget.isGroupChat
              ? (widget.subtitle != null &&
                    widget.subtitle!.isNotEmpty &&
                    !widget.subtitle!.startsWith("0 "))
              : widget.isOnline,
          item: SearchItem(
            id: widget.id,
            name: widget.name,
            bio: widget.subtitle ?? (widget.isOnline ? "active now" : ""),
            profilePicUrl: widget.profilePicUrl,
            email: widget.subtitle ?? "",
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 8, left: 4),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(
            LucideIcons.ellipsisVertical,
            color: iconColor,
            size: 20,
          ),
          color: DefaultColorSheet.cardBg(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            switch (value) {
              case 'info':
                Navigator.pushNamed(
                  context,
                  AppRoutes.userProfile,
                  arguments: UserProfileArguments(
                    id: widget.id,
                    isGroupChat: widget.isGroupChat,
                    name: widget.name,
                    profilePicUrl: widget.profilePicUrl,
                  ),
                );
                break;
              case 'settings':
                Navigator.pushNamed(
                  context,
                  AppRoutes.chatSettings,
                  arguments: ChatSettingsArguments(
                    chatId: widget.id,
                    name: widget.name,
                    profilePicUrl: widget.profilePicUrl,
                    isGroupChat: widget.isGroupChat,
                  ),
                );
                break;
              case 'clear':
                _showClearChatDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(
                    widget.isGroupChat ? LucideIcons.users : LucideIcons.user,
                    size: 18,
                    color: DefaultColorSheet.textPrimary(context),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isGroupChat ? 'Group info' : 'Contact info',
                    style: TextStyle(
                      color: DefaultColorSheet.textPrimary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(
                    LucideIcons.settings,
                    size: 18,
                    color: DefaultColorSheet.textPrimary(context),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Chat settings',
                    style: TextStyle(
                      color: DefaultColorSheet.textPrimary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Clear chat',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: DefaultColorSheet.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Clear this chat?",
          style: TextStyle(color: DefaultColorSheet.textPrimary(context)),
        ),
        content: Text(
          "Messages will only be removed from this device.",
          style: TextStyle(color: DefaultColorSheet.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref
                  .read(chatSettingsTableProvider.notifier)
                  .clearChatHistory(chatId: widget.id);
            },
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
