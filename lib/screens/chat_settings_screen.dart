import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/chat_settings_modal.dart';
import 'package:my_app/providers/tables/chat_settings_table_provider.dart';
import 'package:my_app/providers/user_relationship_provider.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:my_app/widgets/screens/chatSettings/chat_settings_header_card.dart';
import 'package:my_app/widgets/screens/chatSettings/chat_settings_section.dart';
import 'package:my_app/widgets/screens/chatSettings/chat_settings_tile.dart';
import 'package:my_app/widgets/screens/chatSettings/disappearing_messages_dialog.dart';
import 'package:my_app/widgets/screens/chatSettings/media_download_dialog.dart';
import 'package:my_app/widgets/screens/chatSettings/sound_picker_dialog.dart';
import 'package:my_app/widgets/screens/chatSettings/wallpaper_picker_dialog.dart';
import 'package:toastification/toastification.dart';

class ChatSettingsArguments {
  final String chatId;
  final String name;
  final String? profilePicUrl;
  final bool isGroupChat;
  final String? receiverId;

  const ChatSettingsArguments({
    required this.chatId,
    required this.name,
    this.profilePicUrl,
    this.isGroupChat = false,
    this.receiverId,
  });
}

class ChatSettingsScreen extends ConsumerWidget {
  const ChatSettingsScreen({super.key});

  void _showMuteOptions(
    BuildContext context,
    WidgetRef ref,
    String chatId,
    bool isCurrentlyMuted,
  ) {
    if (isCurrentlyMuted) {
      ref.read(chatSettingsTableProvider.notifier).updateMute(
            chatId: chatId,
            isMuted: false,
          );
      ToastHelper.show(
        context: context,
        message: 'Notifications unmuted',
        type: ToastificationType.info,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: DefaultColorSheet.containerBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryText(
                'Mute Notifications For...',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DefaultColorSheet.textPrimary(context),
              ),
              const SizedBox(height: 14),
              _buildMuteTile(
                context,
                title: '8 Hours',
                onTap: () {
                  final until = DateTime.now()
                      .add(const Duration(hours: 8))
                      .millisecondsSinceEpoch;
                  ref.read(chatSettingsTableProvider.notifier).updateMute(
                        chatId: chatId,
                        isMuted: true,
                        mutedUntil: until,
                      );
                  Navigator.pop(ctx);
                },
              ),
              _buildMuteTile(
                context,
                title: '1 Week',
                onTap: () {
                  final until = DateTime.now()
                      .add(const Duration(days: 7))
                      .millisecondsSinceEpoch;
                  ref.read(chatSettingsTableProvider.notifier).updateMute(
                        chatId: chatId,
                        isMuted: true,
                        mutedUntil: until,
                      );
                  Navigator.pop(ctx);
                },
              ),
              _buildMuteTile(
                context,
                title: 'Always',
                onTap: () {
                  ref.read(chatSettingsTableProvider.notifier).updateMute(
                        chatId: chatId,
                        isMuted: true,
                        mutedUntil: null,
                      );
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMuteTile(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, size: 20, color: Colors.grey),
            const SizedBox(width: 14),
            PrimaryText(
              title,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: DefaultColorSheet.textPrimary(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearChat(BuildContext context, WidgetRef ref, String chatId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DefaultColorSheet.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: PrimaryText(
          'Clear Chat History?',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DefaultColorSheet.textPrimary(context),
        ),
        content: PrimaryText(
          'This will permanently delete all messages in this conversation from this device.',
          fontSize: 14,
          color: DefaultColorSheet.textSecondary(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(chatSettingsTableProvider.notifier)
                  .clearChatHistory(chatId: chatId);
              if (context.mounted) {
                ToastHelper.show(
                  context: context,
                  message: 'Chat history cleared',
                  type: ToastificationType.success,
                );
              }
            },
            child: const Text('Clear Chat'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteChat(BuildContext context, WidgetRef ref, String chatId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DefaultColorSheet.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: PrimaryText(
          'Delete Conversation?',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DefaultColorSheet.textPrimary(context),
        ),
        content: PrimaryText(
          'This will delete the conversation and its messages from your chats.',
          fontSize: 14,
          color: DefaultColorSheet.textSecondary(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(chatSettingsTableProvider.notifier)
                  .deleteConversation(chatId: chatId);
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ToastHelper.show(
                  context: context,
                  message: 'Conversation deleted',
                  type: ToastificationType.success,
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDisappearingDuration(int seconds) {
    if (seconds == 0) return 'Off';
    if (seconds == 86400) return '24 Hours';
    if (seconds == 604800) return '7 Days';
    if (seconds == 7776000) return '90 Days';
    return '${seconds ~/ 86400} Days';
  }

  String _formatMediaAutoDownload(String value) {
    switch (value) {
      case 'wifi_only':
        return 'Wi-Fi only';
      case 'always':
        return 'Always';
      case 'never':
        return 'Never';
      default:
        return 'Default';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ChatSettingsArguments;
    final settingsAsync = ref.watch(chatSettingsStreamProvider(args.chatId));
    final settings = settingsAsync.value ?? ChatSettingsModal(chatId: args.chatId);
    final notifier = ref.read(chatSettingsTableProvider.notifier);

    final relationshipStatus = args.receiverId != null && args.receiverId!.isNotEmpty
        ? ref.watch(userRelationshipProvider(args.receiverId!)).value
        : null;
    final relationshipNotifier = args.receiverId != null && args.receiverId!.isNotEmpty
        ? ref.read(userRelationshipProvider(args.receiverId!).notifier)
        : null;

    final isBlocked = relationshipStatus == RelationshipStatus.blocked;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: PrimaryText(
          'Chat Settings',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PrimaryContainer(
        children: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Card
              ChatSettingsHeaderCard(
                name: args.name,
                profilePicUrl: args.profilePicUrl,
                isGroupChat: args.isGroupChat,
                isMuted: settings.isEffectivelyMuted,
                isPinned: settings.isPinned,
                onMuteToggle: () => _showMuteOptions(
                  context,
                  ref,
                  args.chatId,
                  settings.isEffectivelyMuted,
                ),
                onPinToggle: () => notifier.togglePin(chatId: args.chatId),
              ),
              const SizedBox(height: 20),

              // 2. Notifications Section
              ChatSettingsSection(
                title: 'NOTIFICATIONS',
                children: [
                  ChatSettingsTile(
                    icon: settings.isEffectivelyMuted
                        ? Icons.volume_off
                        : Icons.volume_up,
                    title: 'Mute Notifications',
                    subtitle: settings.isEffectivelyMuted
                        ? (settings.mutedUntil != null
                            ? 'Muted'
                            : 'Muted Always')
                        : 'Unmuted',
                    trailing: Switch.adaptive(
                      value: settings.isEffectivelyMuted,
                      activeTrackColor: DefaultColorSheet.primary,
                      onChanged: (_) => _showMuteOptions(
                        context,
                        ref,
                        args.chatId,
                        settings.isEffectivelyMuted,
                      ),
                    ),
                    onTap: () => _showMuteOptions(
                      context,
                      ref,
                      args.chatId,
                      settings.isEffectivelyMuted,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: DefaultColorSheet.divider(context),
                    indent: 52,
                  ),
                  ChatSettingsTile(
                    icon: Icons.music_note,
                    title: 'Notification Sound',
                    subtitle: settings.notificationSound.capitalize(),
                    onTap: () => SoundPickerDialog.show(
                      context,
                      currentSound: settings.notificationSound,
                      onSoundSelected: (sound) => notifier.updateNotificationSound(
                        chatId: args.chatId,
                        sound: sound,
                      ),
                    ),
                  ),
                ],
              ),

              // 3. Appearance Section
              ChatSettingsSection(
                title: 'APPEARANCE',
                children: [
                  ChatSettingsTile(
                    icon: LucideIcons.palette,
                    title: 'Chat Wallpaper',
                    subtitle: settings.wallpaper == null ||
                            settings.wallpaper!.isEmpty
                        ? 'Default wallpaper'
                        : (settings.wallpaper!.startsWith('0x') ||
                                settings.wallpaper!.startsWith('0X')
                            ? 'Color Preset'
                            : 'Custom Image'),
                    onTap: () => WallpaperPickerDialog.show(
                      context,
                      currentWallpaper: settings.wallpaper,
                      onWallpaperSelected: (wall) => notifier.updateWallpaper(
                        chatId: args.chatId,
                        wallpaper: wall,
                      ),
                    ),
                  ),
                ],
              ),

              // 4. Chat Management Section
              ChatSettingsSection(
                title: 'CHAT MANAGEMENT',
                children: [
                  ChatSettingsTile(
                    icon: LucideIcons.pin,
                    title: 'Pin Conversation',
                    subtitle: 'Keep this chat at the top of your chat list',
                    trailing: Switch.adaptive(
                      value: settings.isPinned,
                      activeTrackColor: DefaultColorSheet.primary,
                      onChanged: (val) =>
                          notifier.togglePin(chatId: args.chatId, isPinned: val),
                    ),
                    onTap: () => notifier.togglePin(chatId: args.chatId),
                  ),
                  Divider(
                    height: 1,
                    color: DefaultColorSheet.divider(context),
                    indent: 52,
                  ),
                  ChatSettingsTile(
                    icon: LucideIcons.archive,
                    title: 'Archive Conversation',
                    subtitle: 'Hide this chat from the primary chat list',
                    trailing: Switch.adaptive(
                      value: settings.isArchived,
                      activeTrackColor: DefaultColorSheet.primary,
                      onChanged: (val) => notifier.toggleArchive(
                        chatId: args.chatId,
                        isArchived: val,
                      ),
                    ),
                    onTap: () => notifier.toggleArchive(chatId: args.chatId),
                  ),
                ],
              ),

              // 5. Privacy & Storage Section
              ChatSettingsSection(
                title: 'PRIVACY & STORAGE',
                children: [
                  ChatSettingsTile(
                    icon: Icons.timer_outlined,
                    title: 'Disappearing Messages',
                    subtitle: _formatDisappearingDuration(
                      settings.disappearingDuration,
                    ),
                    onTap: () => DisappearingMessagesDialog.show(
                      context,
                      currentDuration: settings.disappearingDuration,
                      onDurationSelected: (dur) =>
                          notifier.updateDisappearingDuration(
                        chatId: args.chatId,
                        durationSeconds: dur,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: DefaultColorSheet.divider(context),
                    indent: 52,
                  ),
                  ChatSettingsTile(
                    icon: LucideIcons.download,
                    title: 'Media Auto-Download',
                    subtitle: _formatMediaAutoDownload(
                      settings.mediaAutoDownload,
                    ),
                    onTap: () => MediaDownloadDialog.show(
                      context,
                      currentSetting: settings.mediaAutoDownload,
                      onSettingSelected: (val) =>
                          notifier.updateMediaAutoDownload(
                        chatId: args.chatId,
                        setting: val,
                      ),
                    ),
                  ),
                ],
              ),

              // 6. Danger Zone Section
              ChatSettingsSection(
                title: 'DANGER ZONE',
                children: [
                  ChatSettingsTile(
                    icon: LucideIcons.eraser,
                    title: 'Clear Chat History',
                    subtitle: 'Delete all messages locally on this device',
                    isDestructive: true,
                    onTap: () => _confirmClearChat(context, ref, args.chatId),
                  ),
                  Divider(
                    height: 1,
                    color: DefaultColorSheet.divider(context),
                    indent: 52,
                  ),
                  ChatSettingsTile(
                    icon: Icons.delete_outline,
                    title: 'Delete Conversation',
                    subtitle: 'Remove conversation and all history',
                    isDestructive: true,
                    onTap: () => _confirmDeleteChat(context, ref, args.chatId),
                  ),
                  if (args.receiverId != null &&
                      args.receiverId!.isNotEmpty &&
                      relationshipNotifier != null) ...[
                    Divider(
                      height: 1,
                      color: DefaultColorSheet.divider(context),
                      indent: 52,
                    ),
                    ChatSettingsTile(
                      icon: isBlocked ? Icons.lock_open : Icons.block,
                      title: isBlocked ? 'Unblock Contact' : 'Block Contact',
                      subtitle: isBlocked
                          ? 'Allow this user to contact you'
                          : 'Block calls and messages from this contact',
                      isDestructive: !isBlocked,
                      onTap: () async {
                        if (isBlocked) {
                          await relationshipNotifier.unblockUser();
                          if (context.mounted) {
                            ToastHelper.show(
                              context: context,
                              message: 'Contact unblocked',
                              type: ToastificationType.info,
                            );
                          }
                        } else {
                          await relationshipNotifier.blockUser();
                          if (context.mounted) {
                            ToastHelper.show(
                              context: context,
                              message: 'Contact blocked',
                              type: ToastificationType.error,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

extension _StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

