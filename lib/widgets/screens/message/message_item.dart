import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/screens/message/message_item_model.dart';
import 'package:my_app/modal/screens/message/message_modal.dart';
import 'package:my_app/modal/tables/chat_events_table.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/message/attachments_list_widget.dart';
import 'package:my_app/widgets/screens/message/delete_message_dialog.dart';
import 'package:my_app/widgets/screens/message/message_bubble.dart';
import 'package:my_app/widgets/screens/message/reaction_details_sheet.dart';
import 'package:my_app/widgets/screens/message/reaction_picker.dart';
import 'package:my_app/widgets/screens/message/reaction_pills.dart';

Widget _statusIcon(MessageStatus status) {
  switch (status) {
    case MessageStatus.sending:
      return Icon(LucideIcons.clock, size: 12, color: Colors.grey.shade400);

    case MessageStatus.sent:
      return Icon(LucideIcons.check, size: 12, color: Colors.grey.shade400);

    case MessageStatus.delivered:
      return Icon(
        LucideIcons.checkCheck,
        size: 12,
        color: Colors.grey.shade400,
      );

    case MessageStatus.read:
      return const Icon(
        LucideIcons.checkCheck,
        size: 12,
        color: Color(0xFF4FC3F7),
      );

    case MessageStatus.failed:
      return const Icon(
        LucideIcons.circleAlert,
        size: 12,
        color: Colors.redAccent,
      );
  }
}

Color _getSenderColor(String name) {
  const colors = [
    Color(0xFF7C4DFF),
    Color(0xFF2979FF),
    Color(0xFF00BCD4),
    Color(0xFFFF6D00),
    Color(0xFFE91E63),
    Color(0xFF00897B),
    Color(0xFF5C6BC0),
    Color(0xFFE53935),
  ];

  return colors[name.hashCode.abs() % colors.length];
}

MessageAlignment _resolveAlignment(
  ChatEventAlignment? eventAlignment,
  bool isSender,
) {
  if (eventAlignment == null) {
    return isSender ? MessageAlignment.right : MessageAlignment.left;
  }

  return switch (eventAlignment) {
    ChatEventAlignment.left => MessageAlignment.left,
    ChatEventAlignment.center => MessageAlignment.center,
    ChatEventAlignment.right => MessageAlignment.right,
  };
}

EdgeInsets _visualMediaMargin(MessageAlignment alignment, bool isGrouped) {
  final horizontal = switch (alignment) {
    MessageAlignment.left => (8.0, 60.0),
    MessageAlignment.center => (24.0, 24.0),
    MessageAlignment.right => (60.0, 8.0),
  };

  return EdgeInsets.fromLTRB(
    horizontal.$1,
    isGrouped ? 1 : 4,
    horizontal.$2,
    0,
  );
}

class MessageItem extends ConsumerWidget {
  final MessageItemModel data;
  final void Function(MessageItemModel data)? onReply;
  final void Function(String messageId, String emoji)? onReact;
  final void Function(MessageItemModel data, bool deleteForEveryone)? onDelete;
  final void Function(MessageItemModel data)? onEdit;
  final void Function(MessageItemModel data)? onPin;
  final void Function(MessageItemModel data)? onForward;
  final void Function(MessageItemModel data)? onSelect;
  final void Function(MessageItemModel data)? onInfo;
  final VoidCallback? onSelectionTap;
  final bool isSelected;
  final bool isSelecting;
  final bool isGroupAdmin;

  const MessageItem({
    super.key,
    required this.data,
    this.onReply,
    this.onReact,
    this.onDelete,
    this.onEdit,
    this.onPin,
    this.onForward,
    this.onSelect,
    this.onInfo,
    this.onSelectionTap,
    this.isSelected = false,
    this.isSelecting = false,
    this.isGroupAdmin = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMediaOnly = !data.isDeleted &&
        data.attachments.isNotEmpty &&
        data.message.isEmpty;
    final hasVisualMedia = !data.isDeleted &&
        data.attachments.any(
          (attachment) =>
              attachment.contentType?.startsWith('image/') == true ||
              attachment.contentType?.startsWith('video/') == true,
        );

    final timeStr = DateFormat(
      'hh:mm a',
    ).format(DateTime.fromMillisecondsSinceEpoch(data.timestamp));
    final bubbleAlignment = _resolveAlignment(
      data.eventAlignment,
      data.isSender,
    );

    final bubble = MessageBubble(
      alignment: bubbleAlignment,
      isGrouped: data.isGrouped,
      padding: isMediaOnly ? const EdgeInsets.all(3) : null,
      backgroundColor: isMediaOnly ? Colors.transparent : null,
      margin: hasVisualMedia
          ? _visualMediaMargin(bubbleAlignment, data.isGrouped)
          : null,
      maxWidthFactor: hasVisualMedia ? .82 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.isDeleted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.ban,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'This message was deleted',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                      color: DefaultColorSheet.textSecondary(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TimestampChip(
                    timeStr: timeStr,
                    isSender: data.isSender,
                    status: null,
                    overlayOnMedia: false,
                  ),
                ],
              ),
            )
          else ...[
            // Quoted reply block
            if (data.replyToMessage != null &&
                data.replyToMessage!.isNotEmpty) ...[
              _QuotedReplyPreview(
                senderName: data.replyToSenderName ?? 'Reply',
                message: data.replyToMessage ?? '',
                isSender: data.isSender,
              ),
              const SizedBox(height: 4),
            ],

            // Group sender name
            if (!data.isSender && data.isGroupChat && !data.isGrouped) ...[
              PrimaryText(
                data.senderName,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _getSenderColor(data.senderName),
              ),
              const SizedBox(height: 2),
            ],

            // Attachments
            if (data.attachments.isNotEmpty) ...[
              AttachmentsListWidget(
                attachments: data.attachments,
                senderName: data.senderName,
                sentAt: data.timestamp,
              ),
              if (data.message.isNotEmpty) const SizedBox(height: 5),
            ],

            // Text + timestamp row
            if (data.message.isNotEmpty || !isMediaOnly)
              _TextWithTimestamp(
                message: data.message,
                timeStr: timeStr,
                isSender: data.isSender,
                status: data.status,
                isMediaOnly: isMediaOnly,
                isEdited: data.isEdited,
                isPinned: data.isPinned,
                onTimestampTap: (data.isSender && onInfo != null && !isSelecting)
                    ? () => onInfo!(data)
                    : null,
              ),

            // Timestamp for media-only messages
            if (isMediaOnly)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 3, right: 2, bottom: 2),
                  child: _TimestampChip(
                    timeStr: timeStr,
                    isSender: data.isSender,
                    status: data.status,
                    overlayOnMedia: true,
                    isEdited: data.isEdited,
                    isPinned: data.isPinned,
                    onTap: (data.isSender && onInfo != null && !isSelecting)
                        ? () => onInfo!(data)
                        : null,
                  ),
                ),
              ),
          ],
        ],
      ),
    );

    final gestureBubble = data.isDeleted
        ? bubble
        : GestureDetector(
            onTap: isSelecting ? onSelectionTap : null,
            onLongPressStart: (details) async {
              if (isSelecting) {
                onSelectionTap?.call();
                return;
              }

              final myEmojis = data.reactions
                  .where((r) => r.hasReactedByMe)
                  .map((r) => r.emoji)
                  .toSet();

              final result = await showMessageContextMenu(
                context,
                tapPosition: details.globalPosition,
                isSender: data.isSender,
                myReactedEmojis: myEmojis,
                canReply: onReply != null,
                canCopy: data.message.isNotEmpty,
                canEdit: data.isSender &&
                    !data.isDeleted &&
                    data.message.isNotEmpty &&
                    onEdit != null,
                canPin: onPin != null && !data.isDeleted,
                isPinned: data.isPinned,
                canForward: onForward != null && !data.isDeleted,
                canSelect: onSelect != null && !data.isDeleted,
                canInfo: data.isSender && !data.isDeleted && onInfo != null,
                canDelete: onDelete != null,
                messageText: data.message,
              );

              if (result == null) return;

              switch (result.action) {
                case MessageContextActionType.react:
                  if (result.emoji != null && onReact != null) {
                    onReact!(data.id, result.emoji!);
                  }
                  break;
                case MessageContextActionType.reply:
                  onReply?.call(data);
                  break;
                case MessageContextActionType.copy:
                  break;
                case MessageContextActionType.edit:
                  onEdit?.call(data);
                  break;
                case MessageContextActionType.pin:
                  onPin?.call(data);
                  break;
                case MessageContextActionType.forward:
                  onForward?.call(data);
                  break;
                case MessageContextActionType.select:
                  onSelect?.call(data);
                  break;
                case MessageContextActionType.info:
                  onInfo?.call(data);
                  break;
                case MessageContextActionType.delete:
                  final canDeleteForEveryone = data.isSender || isGroupAdmin;
                  if (!context.mounted) break;
                  final deleteType = await showDeleteMessageDialog(
                    context,
                    canDeleteForEveryone: canDeleteForEveryone,
                  );
                  if (deleteType != null && onDelete != null) {
                    onDelete!(data, deleteType == DeleteMessageType.everyone);
                  }
                  break;
              }
            },
            onDoubleTap: (!isSelecting && onReply != null)
                ? () => onReply!(data)
                : null,
            child: bubble,
          );

    final itemWithReactions = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          data.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        gestureBubble,
        if (!data.isDeleted && data.reactions.isNotEmpty)
          ReactionPills(
            reactions: data.reactions,
            isSender: data.isSender,
            onTap: (emoji) {
              onReact?.call(data.id, emoji);
            },
            onLongPress: (reactions) {
              showReactionDetailsSheet(context, reactions);
            },
          ),
      ],
    );

    final wrappedBubble = Container(
      width: double.infinity,
      color: isSelected
          ? DefaultColorSheet.green500.withValues(alpha: 0.16)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: itemWithReactions,
    );

    if (onReply == null || data.isDeleted || isSelecting) {
      return wrappedBubble;
    }

    return Dismissible(
      key: ValueKey('msg_${data.id}_${data.timestamp}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        onReply!(data);
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(
          LucideIcons.reply,
          size: 20,
          color: DefaultColorSheet.green500,
        ),
      ),
      child: wrappedBubble,
    );
  }
}

class _QuotedReplyPreview extends StatelessWidget {
  final String senderName;
  final String message;
  final bool isSender;

  const _QuotedReplyPreview({
    required this.senderName,
    required this.message,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isSender
            ? Colors.black.withValues(alpha: 0.06)
            : Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(
            color: isSender
                ? const Color(0xFF005C4B)
                : const Color(0xFF00A884),
            width: 3.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            senderName.isEmpty ? "Reply" : senderName,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isSender
                  ? const Color(0xFF005C4B)
                  : const Color(0xFF00A884),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: DefaultColorSheet.textSecondary(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Renders text inline with timestamp tucked to the right — like WhatsApp/Telegram.
class _TextWithTimestamp extends StatelessWidget {
  final String message;
  final String timeStr;
  final bool isSender;
  final MessageStatus? status;
  final bool isMediaOnly;
  final bool isEdited;
  final bool isPinned;
  final VoidCallback? onTimestampTap;

  const _TextWithTimestamp({
    required this.message,
    required this.timeStr,
    required this.isSender,
    required this.status,
    required this.isMediaOnly,
    this.isEdited = false,
    this.isPinned = false,
    this.onTimestampTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isMediaOnly) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            message,
            style: TextStyle(
              color: DefaultColorSheet.bubbleText(context),
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(width: 6),
        _TimestampChip(
          timeStr: timeStr,
          isSender: isSender,
          status: status,
          overlayOnMedia: false,
          isEdited: isEdited,
          isPinned: isPinned,
          onTap: onTimestampTap,
        ),
      ],
    );
  }
}

class _TimestampChip extends StatelessWidget {
  final String timeStr;
  final bool isSender;
  final MessageStatus? status;
  final bool overlayOnMedia;
  final bool isEdited;
  final bool isPinned;
  final VoidCallback? onTap;

  const _TimestampChip({
    required this.timeStr,
    required this.isSender,
    required this.status,
    required this.overlayOnMedia,
    this.isEdited = false,
    this.isPinned = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isPinned) ...[
          Icon(
            LucideIcons.pin,
            size: 10,
            color: overlayOnMedia
                ? Colors.white.withValues(alpha: 0.85)
                : DefaultColorSheet.bubbleTime(context, isSender: isSender),
          ),
          const SizedBox(width: 3),
        ],
        if (isEdited) ...[
          Text(
            'edited',
            style: TextStyle(
              fontSize: 9.5,
              fontStyle: FontStyle.italic,
              color: overlayOnMedia
                  ? Colors.white.withValues(alpha: 0.85)
                  : DefaultColorSheet.bubbleTime(context, isSender: isSender),
            ),
          ),
          const SizedBox(width: 3),
        ],
        Text(
          timeStr,
          style: TextStyle(
            fontSize: 10,
            color: overlayOnMedia
                ? Colors.white
                : DefaultColorSheet.bubbleTime(context, isSender: isSender),
            fontWeight: FontWeight.w400,
          ),
        ),
        if (isSender && status != null) ...[
          const SizedBox(width: 3),
          _statusIcon(status!),
        ],
      ],
    );

    final effectiveWidget = overlayOnMedia
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: timeWidget,
            ),
          )
        : timeWidget;

    if (onTap == null) return effectiveWidget;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: effectiveWidget,
    );
  }
}
