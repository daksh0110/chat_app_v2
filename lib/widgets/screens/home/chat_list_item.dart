import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/providers/message_typing_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ChatListItem extends ConsumerWidget {
  const ChatListItem({super.key, required this.chat, this.onTap});

  final ChatListModal chat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typingMap = ref.watch(messageTypingProvider);
    final isTyping = typingMap[chat.chatId] ?? false;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              ClipOval(
                child: Image.asset(
                  chat.profilePic,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryText(
                      chat.name,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: DefaultColorSheet.lightBlack,
                    ),
                    const SizedBox(height: 4),
                    isTyping
                        ? PrimaryText(
                            "typing...",
                            fontSize: 12,
                            color: DefaultColorSheet.green500,
                          )
                        : PrimaryText(
                            chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12,
                            color: DefaultColorSheet.grey500,
                          ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PrimaryText(
                    chat.lastMessageTime,
                    fontSize: 12,
                    color: DefaultColorSheet.grey500,
                  ),
                  const SizedBox(height: 6),

                  if (chat.unReadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DefaultColorSheet.red100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chat.unReadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
