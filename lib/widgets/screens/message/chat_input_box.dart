import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class ChatInputBox extends StatefulWidget {
  final Function(String) onSend;
  final Function() onTyping;
  final Function() onStopTyping;
  const ChatInputBox({
    super.key,
    required this.onSend,
    required this.onTyping,
    required this.onStopTyping,
  });

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  final chatMessageController = TextEditingController();
  bool _isTyping = false;
  void onTyping(String text) {
    setState(() {
      _isTyping = text.isNotEmpty;
    });

    if (text.isEmpty) {
      widget.onStopTyping();
      return;
    }

    widget.onTyping();
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
                child: _isTyping
                    ? InkWell(
                        key: const ValueKey('send'),
                        onTap: () {
                          final text = chatMessageController.text.trim();
                          if (text.isEmpty) return;
                          widget.onSend(text);
                          widget.onStopTyping();
                          setState(() {
                            _isTyping = false;
                          });
                          chatMessageController.clear();
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
