import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/screens/message/message_modal.dart';
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
      return const Icon(LucideIcons.checkCheck, size: 12, color: Color(0xFF4FC3F7));

    case MessageStatus.failed:
      return const Icon(LucideIcons.circleAlert, size: 12, color: Colors.redAccent);
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

class MessageItem extends ConsumerWidget {
  final String message;
  final bool isSender;
  final MessageStatus? status;
  final int timestamp;
  final String senderName;
  final bool isGroupChat;
  final List<MediaTableData> attachments;

  final bool isGrouped;

  const MessageItem({
    super.key,
    required this.message,
    required this.isSender,
    this.status,
    required this.timestamp,
    required this.senderName,
    this.isGroupChat = false,
    this.attachments = const [],
    this.isGrouped = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMediaOnly = attachments.isNotEmpty && message.isEmpty;
    final hasVisualMedia = attachments.any(
      (attachment) =>
          attachment.contentType?.startsWith('image/') == true ||
          attachment.contentType?.startsWith('video/') == true,
    );

    final timeStr = DateFormat('hh:mm a').format(
      DateTime.fromMillisecondsSinceEpoch(timestamp),
    );

    return MessageBubble(
      alignment: isSender ? MessageAlignment.right : MessageAlignment.left,
      isGrouped: isGrouped,
      padding: isMediaOnly ? const EdgeInsets.all(3) : null,
      backgroundColor: isMediaOnly ? Colors.transparent : null,
      margin: hasVisualMedia
          ? EdgeInsets.fromLTRB(
              isSender ? 60 : 8,
              isGrouped ? 1 : 4,
              isSender ? 8 : 60,
              0,
            )
          : null,
      maxWidthFactor: hasVisualMedia ? .82 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Group sender name
          if (!isSender && isGroupChat && !isGrouped) ...[
            PrimaryText(
              senderName,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _getSenderColor(senderName),
            ),
            const SizedBox(height: 2),
          ],

          // Attachments
          if (attachments.isNotEmpty) ...[
            AttachmentsListWidget(
              attachments: attachments,
              senderName: senderName,
              sentAt: timestamp,
            ),
            if (message.isNotEmpty) const SizedBox(height: 5),
          ],

          // Text + timestamp row
          if (message.isNotEmpty || !isMediaOnly)
            _TextWithTimestamp(
              message: message,
              timeStr: timeStr,
              isSender: isSender,
              status: status,
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
                  isSender: isSender,
                  status: status,
                  overlayOnMedia: true,
                ),
              ),
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
