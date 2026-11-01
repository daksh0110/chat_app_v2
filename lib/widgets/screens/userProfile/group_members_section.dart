import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/group_profile_modal.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';

class GroupMembersSection extends StatelessWidget {
  const GroupMembersSection({
    super.key,
    required this.members,
    required this.currentUserId,
    required this.canManageMembers,
    required this.onRemoveMember,
  });

  final List<GroupMember> members;
  final String currentUserId;
  final bool canManageMembers;
  final ValueChanged<String> onRemoveMember;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PrimaryText(
          'Group Members',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: DefaultColorSheet.grey500,
        ),
        const SizedBox(height: 14),
        if (members.isEmpty)
          const PrimaryText('No members found', textAlign: TextAlign.center),
        ...members.map(_memberTile),
      ],
    );
  }

  Widget _memberTile(GroupMember member) {
    final isMe = currentUserId == member.userId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          UserBubble(
            profilePicUrl: member.profilePicUrl,
            name: member.name,
            size: 40,
            needActiveIndicator: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrimaryText(
                  isMe ? '${member.name} (You)' : member.name,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                PrimaryText(
                  member.role == 'ADMIN' ? 'Admin' : 'Member',
                  color: DefaultColorSheet.grey500,
                  fontSize: 14,
                ),
              ],
            ),
          ),
          if (canManageMembers && !isMe)
            IconButton(
              tooltip: 'Remove member',
              icon: const Icon(Icons.person_remove_outlined),
              onPressed: () => onRemoveMember(member.userId),
            ),
        ],
      ),
    );
  }
}
