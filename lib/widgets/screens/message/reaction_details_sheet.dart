import 'package:flutter/material.dart';
import 'package:my_app/modal/message_reaction_modal.dart';

/// A bottom sheet that shows who reacted with which emoji.
/// Tabs at the top for each emoji, listing users underneath.
void showReactionDetailsSheet(
  BuildContext context,
  List<ReactionGroup> reactions,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return DefaultTabController(
        length: reactions.length,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Tab bar with emojis
            TabBar(
              isScrollable: true,
              labelColor: const Color(0xFF00A884),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF00A884),
              tabAlignment: TabAlignment.start,
              tabs: reactions.map((group) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(group.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(
                        '${group.count}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const Divider(height: 1),

            // Tab views listing users
            SizedBox(
              height: 200,
              child: TabBarView(
                children: reactions.map((group) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: group.users.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final user = group.users[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(
                          user.name.isNotEmpty ? user.name : user.userId,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

