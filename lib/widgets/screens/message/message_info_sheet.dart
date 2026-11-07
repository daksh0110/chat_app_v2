import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/util/getDatelabel.dart';
import 'package:my_app/modal/screens/message/message_item_model.dart';
import 'package:my_app/providers/tables/message_status_table_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class MessageInfoSheet extends ConsumerWidget {
  final MessageItemModel message;
  final String chatId;
  final bool isGroup;

  const MessageInfoSheet({
    super.key,
    required this.message,
    required this.chatId,
    required this.isGroup,
  });

  static Future<void> show(
    BuildContext context, {
    required MessageItemModel message,
    required String chatId,
    required bool isGroup,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageInfoSheet(
        message: message,
        chatId: chatId,
        isGroup: isGroup,
      ),
    );
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '—';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final timeStr = DateFormat('h:mm a').format(date);
    final label = getDateLabel(timestamp);
    if (label == 'Today') return 'Today, $timeStr';
    if (label == 'Yesterday') return 'Yesterday, $timeStr';
    return '${DateFormat('MMM d').format(date)}, $timeStr';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardBg = DefaultColorSheet.surfaceBg(context);
    final textPrimary = DefaultColorSheet.textPrimary(context);
    final textSecondary = DefaultColorSheet.textSecondary(context);
    final dividerColor = DefaultColorSheet.divider(context);

    final infoAsync = ref.watch(
      messageInfoProvider((
        messageId: message.id,
        serverId: message.serverId,
        chatId: chatId,
        isGroup: isGroup,
      )),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              padding: const EdgeInsets.fromLTRB(18, 4, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryText(
                      'Message Info',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  IconButton(
                    splashRadius: 20,
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Message preview bubble
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DefaultColorSheet.bubbleSender(context),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.message.isNotEmpty)
                    PrimaryText(
                      message.message,
                      fontSize: 14.5,
                      color: DefaultColorSheet.bubbleText(context),
                      maxLines: 4,
                    ),
                  if (message.attachments.isNotEmpty) ...[
                    if (message.message.isNotEmpty) const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.paperclip,
                          size: 14,
                          color: DefaultColorSheet.green500,
                        ),
                        const SizedBox(width: 4),
                        PrimaryText(
                          '${message.attachments.length} ${message.attachments.length == 1 ? "attachment" : "attachments"}',
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PrimaryText(
                        'Sent: ${_formatTime(message.timestamp)}',
                        fontSize: 11,
                        color: DefaultColorSheet.bubbleTime(
                          context,
                          isSender: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: dividerColor),

            // Status lists / details
            Flexible(
              child: infoAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: PrimaryText(
                      'Error loading status: $e',
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ),
                data: (info) {
                  if (!isGroup) {
                    return _buildDirectChatStatus(
                      context,
                      info,
                      textPrimary,
                      textSecondary,
                      dividerColor,
                    );
                  }

                  return _buildGroupChatStatus(
                    context,
                    info,
                    textPrimary,
                    textSecondary,
                    dividerColor,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectChatStatus(
    BuildContext context,
    MessageInfoData info,
    Color textPrimary,
    Color textSecondary,
    Color dividerColor,
  ) {
    final readRecipient = info.readBy.isNotEmpty ? info.readBy.first : null;
    final deliveredRecipient =
        info.deliveredTo.isNotEmpty ? info.deliveredTo.first : null;

    final readTime = readRecipient?.readAt;
    final deliveredTime = deliveredRecipient?.deliveredAt ?? readRecipient?.deliveredAt;

    final isRead = readTime != null && readTime > 0;
    final isDelivered = deliveredTime != null && deliveredTime > 0;

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Read Row
        _StatusTile(
          icon: LucideIcons.checkCheck,
          iconColor: isRead ? const Color(0xFF4FC3F7) : Colors.grey.shade400,
          title: 'Read',
          subtitle: isRead ? _formatTime(readTime) : 'Not read yet',
          isCompleted: isRead,
        ),
        Divider(height: 16, indent: 44, color: dividerColor),

        // Delivered Row
        _StatusTile(
          icon: LucideIcons.checkCheck,
          iconColor: isDelivered ? Colors.grey.shade500 : Colors.grey.shade400,
          title: 'Delivered',
          subtitle: isDelivered ? _formatTime(deliveredTime) : 'Not delivered yet',
          isCompleted: isDelivered,
        ),
      ],
    );
  }

  Widget _buildGroupChatStatus(
    BuildContext context,
    MessageInfoData info,
    Color textPrimary,
    Color textSecondary,
    Color dividerColor,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Read By Section
        _buildSectionHeader(
          icon: LucideIcons.checkCheck,
          iconColor: const Color(0xFF4FC3F7),
          title: 'Read by',
          count: '${info.readBy.length} of ${info.totalParticipants}',
          textPrimary: textPrimary,
        ),
        if (info.readBy.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 4, 16, 12),
            child: PrimaryText(
              'No one has read yet',
              fontSize: 13,
              color: textSecondary,
            ),
          )
        else
          ...info.readBy.map(
            (r) => _RecipientTile(
              recipient: r,
              time: _formatTime(r.readAt),
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),

        Divider(height: 20, indent: 16, endIndent: 16, color: dividerColor),

        // Delivered To Section
        _buildSectionHeader(
          icon: LucideIcons.checkCheck,
          iconColor: Colors.grey.shade500,
          title: 'Delivered to',
          count: '${info.deliveredTo.length} of ${info.totalParticipants}',
          textPrimary: textPrimary,
        ),
        if (info.deliveredTo.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 4, 16, 12),
            child: PrimaryText(
              'No pending deliveries',
              fontSize: 13,
              color: textSecondary,
            ),
          )
        else
          ...info.deliveredTo.map(
            (r) => _RecipientTile(
              recipient: r,
              time: _formatTime(r.deliveredAt),
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),

        // Remaining / Not yet delivered Section
        if (info.remaining.isNotEmpty) ...[
          Divider(height: 20, indent: 16, endIndent: 16, color: dividerColor),
          _buildSectionHeader(
            icon: LucideIcons.clock,
            iconColor: Colors.grey.shade400,
            title: 'Not yet delivered',
            count: '${info.remaining.length}',
            textPrimary: textPrimary,
          ),
          ...info.remaining.map(
            (r) => _RecipientTile(
              recipient: r,
              time: 'Pending',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String count,
    required Color textPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: PrimaryText(
              title,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          PrimaryText(
            count,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: iconColor,
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isCompleted;

  const _StatusTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrimaryText(
                  title,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: DefaultColorSheet.textPrimary(context),
                ),
                const SizedBox(height: 2),
                PrimaryText(
                  subtitle,
                  fontSize: 12.5,
                  color: isCompleted
                      ? DefaultColorSheet.textSecondary(context)
                      : DefaultColorSheet.grey500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientTile extends StatelessWidget {
  final MessageRecipientStatus recipient;
  final String time;
  final Color textPrimary;
  final Color textSecondary;

  const _RecipientTile({
    required this.recipient,
    required this.time,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidPic = recipient.profilePicUrl != null &&
        File(recipient.profilePicUrl!).existsSync();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          ClipOval(
            child: hasValidPic
                ? Image.file(
                    File(recipient.profilePicUrl!),
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF075E54),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: PrimaryText(
                      recipient.name.isNotEmpty
                          ? recipient.name[0].toUpperCase()
                          : '?',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryText(
              recipient.name,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
          PrimaryText(
            time,
            fontSize: 12,
            color: textSecondary,
          ),
        ],
      ),
    );
  }
}
