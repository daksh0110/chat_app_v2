import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class ChatInputBox extends StatefulWidget {
  final Function(String) onSend;

  const ChatInputBox({super.key, required this.onSend});

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  bool isTyping = false;
  final chatMessageController = TextEditingController();

  void onTyping(String text) {
    if (text.isEmpty) {
      setState(() {
        isTyping = false;
      });
    } else {
      setState(() {
        isTyping = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 90,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: DefaultColorSheet.white100, width: 1),
        ),
      ),
      child: Center(
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                LucideIcons.paperclip,
                size: 24,
                color: DefaultColorSheet.lightBlack,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: DefaultColorSheet.disbaledButton,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: TextField(
                  controller: chatMessageController,
                  onChanged: onTyping,
                  minLines: 1,
                  maxLines: 4,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.copy),
                    ),
                    border: InputBorder.none,
                    hintText: "Write a message",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: DefaultColorSheet.grey500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: isTyping
                    ? InkWell(
                        key: const ValueKey('send'),
                        onTap: () {
                          final text = chatMessageController.text.trim();
                          if (text.isEmpty) return;

                          widget.onSend(text);

                          chatMessageController.clear();
                          setState(() {
                            isTyping = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(11),
                          decoration: const BoxDecoration(
                            color: DefaultColorSheet.green500,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.sendHorizontal,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        key: const ValueKey('media'),
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Icon(
                            LucideIcons.camera,
                            size: 24,
                            color: DefaultColorSheet.lightBlack,
                          ),
                          SizedBox(width: 8),
                          Icon(
                            LucideIcons.mic,
                            size: 24,
                            color: DefaultColorSheet.lightBlack,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
