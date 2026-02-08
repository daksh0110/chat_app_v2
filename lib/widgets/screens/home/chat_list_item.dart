import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({super.key, required this.chat, this.onTap});

  final ChatListModal chat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
        child: Row(
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

            // Name + Last message
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
                  PrimaryText(
                    chat.lastMessage,
                    fontSize: 12,
                    color: DefaultColorSheet.grey500,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Time + Unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PrimaryText(
                  chat.lastMessageAt,
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
    );
  }
}
