import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/providers/message_typing_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ChatListItem extends ConsumerWidget {
  const ChatListItem({
    super.key,
    required this.chat,
    this.onTap,
    this.onHold,
    this.isSelected = false,
  });

  final ChatListModal chat;
  final VoidCallback? onTap;
  final VoidCallback? onHold;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typingMap = ref.watch(messageTypingProvider);
    final isTyping = typingMap[chat.chatId] ?? false;
    final isProfilePicValid = (chat.profilePicUrl != null &&
            Uri.tryParse(chat.profilePicUrl!)?.hasAbsolutePath == true)
        ? true
        : false;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: isSelected ? Colors.transparent : DefaultColorSheet.blue200,
        onLongPress: onHold,
        highlightColor: DefaultColorSheet.blue200,
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? DefaultColorSheet.blue200 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              ClipOval(
                child: isProfilePicValid
                    ? Image.network(
                        chat.profilePicUrl!,
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                      )
                    : Container(

                        decoration: BoxDecoration(
                          color: Color(0xFF075E54),
                          shape: BoxShape.circle,
                        ),
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        child: PrimaryText(
                          chat.name.isNotEmpty
                              ? chat.name[0].toUpperCase()
                              : "",
                          color: Colors.white,
                          fontSize: 26,
                        ),
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
