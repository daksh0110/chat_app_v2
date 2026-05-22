import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/screens/message/message_modal.dart';
import 'package:my_app/modal/tables/media_modal.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/message/attachments_list_widget.dart';

Widget _statusIcon(MessageStatus status) {
  switch (status) {
    case MessageStatus.sending:
      return const Icon(LucideIcons.clock, size: 10, color: Colors.white);

    case MessageStatus.sent:
      return const Icon(LucideIcons.check, size: 10, color: Colors.white);

    case MessageStatus.delivered:
      return const Icon(LucideIcons.checkCheck, size: 10, color: Colors.white);

    case MessageStatus.read:
      return const Icon(LucideIcons.checkCheck, size: 10, color: Colors.red);

    case MessageStatus.failed:
      return const Icon(LucideIcons.circleAlert, size: 10, color: Colors.red);
  }
}

Color _getSenderColor(String name) {
  final colors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.teal,
    Colors.orange,
    Colors.pink,
    Colors.green,
    Colors.indigo,
    Colors.red,
  ];

  return colors[name.hashCode % colors.length];
}

class MessageItem extends ConsumerWidget {
  final String message;
  final bool isSender;
  final MessageStatus? status;
  final int timestamp;
  final String senderName;
  final bool isGroupChat;
  final List<MediaTableData> attachments;

  const MessageItem({
    super.key,
    required this.message,
    required this.isSender,
    this.status,
    required this.timestamp,
    required this.senderName,
    this.isGroupChat = false,
    this.attachments = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isSender
              ? DefaultColorSheet.green500
              : const Color(0xFFF2F7FB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isSender ? 16 : 0),
            topRight: Radius.circular(isSender ? 0 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 0, bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSender && isGroupChat) ...[
                    PrimaryText(
                      senderName,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getSenderColor(senderName),
                    ),

                    const SizedBox(height: 2),
                  ],

                  if (attachments.isNotEmpty) ...[
                    AttachmentsListWidget(attachments: attachments),
                    if (message.isNotEmpty) const SizedBox(height: 6),
                  ],

                  if (message.isNotEmpty)
                    PrimaryText(
                      message,
                      color: isSender ? Colors.white : Colors.black,
                    ),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryText(
                    DateFormat(
                      'hh:mm a',
                    ).format(DateTime.fromMillisecondsSinceEpoch(timestamp)),
                    fontSize: 8,
                    color: isSender ? Colors.white70 : Colors.black54,
                  ),

                  if (isSender && status != null) ...[
                    const SizedBox(width: 4),
                    _statusIcon(status!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
