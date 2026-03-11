import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/screens/message/message_modal.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

Widget _statusIcon(MessageStatus status) {
  switch (status) {
    case MessageStatus.sending:
      return const Icon(LucideIcons.clock, size: 10, color: Colors.white);

    case MessageStatus.sent:
      return const Icon(LucideIcons.check, size: 10, color: Colors.white);

    case MessageStatus.delivered:
      return const Icon(LucideIcons.checkCheck, size: 10, color: Colors.white);

    case MessageStatus.read:
      return const Icon(LucideIcons.checkCheck, size: 10, color: Colors.blue);

    case MessageStatus.failed:
      return const Icon(LucideIcons.circleAlert, size: 10, color: Colors.red);
  }
}

class MessageItem extends ConsumerWidget {
  final String message;
  final bool isSender;
  final MessageStatus status;

  const MessageItem({
    super.key,
    required this.message,
    required this.isSender,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: EdgeInsets.fromLTRB(10, 14, 10, isSender ? 20 : 14),
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
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: PrimaryText(
                message,
                color: isSender ? Colors.white : Colors.black,
              ),
            ),
            Positioned(bottom: -10, right: 0, child: _statusIcon(status)),
          ],
        ),
      ),
    );
  }
}
