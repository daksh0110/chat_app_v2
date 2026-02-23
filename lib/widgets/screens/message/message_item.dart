import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class MessageItem extends ConsumerWidget {
  final String message;
  final bool isSender;

  const MessageItem({super.key, required this.message, required this.isSender});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isSender
              ? DefaultColorSheet.green500
              : const Color(0xFFF2F7FB),
          borderRadius: BorderRadius.only(
            // 🔥 THIS is the fix
            topLeft: Radius.circular(isSender ? 16 : 0),
            topRight: Radius.circular(isSender ? 0 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: PrimaryText(
          message,
          color: isSender ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
