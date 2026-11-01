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
import 'package:my_app/widgets/screens/message/message_bubble.dart';

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

  const MessageItem({super.key, required this.data, this.onReply});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMediaOnly = data.attachments.isNotEmpty && data.message.isEmpty;
    final hasVisualMedia = data.attachments.any(
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
                ),
              ),
            ),
        ],
      ),
    );

    final gestureBubble = GestureDetector(
      onLongPress: onReply != null ? () => onReply!(data) : null,
      onDoubleTap: onReply != null ? () => onReply!(data) : null,
      child: bubble,
    );

    if (onReply == null) return gestureBubble;

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
      child: gestureBubble,
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
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF3B4A54),
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

  const _TextWithTimestamp({
    required this.message,
    required this.timeStr,
    required this.isSender,
    required this.status,
    required this.isMediaOnly,
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
            style: const TextStyle(
              color: Color(0xFF111B21),
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

  const _TimestampChip({
    required this.timeStr,
    required this.isSender,
    required this.status,
    required this.overlayOnMedia,
  });

  @override
  Widget build(BuildContext context) {
    final timeWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          timeStr,
          style: TextStyle(
            fontSize: 10,
            color: overlayOnMedia ? Colors.white : const Color(0xFF8696A0),
            fontWeight: FontWeight.w400,
          ),
        ),
        if (isSender && status != null) ...[
          const SizedBox(width: 3),
          _statusIcon(status!),
        ],
      ],
    );

    if (!overlayOnMedia) return timeWidget;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: timeWidget,
      ),
    );
  }
}
