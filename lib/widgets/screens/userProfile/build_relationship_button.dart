import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/providers/user_relationship_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

Widget buildRelationshipButton(
  RelationshipStatus status,
  UserRelationshipNotifier notifier,
  bool isLoading, {
  BuildContext? context,
  String? userName,
  String? profilePicUrl,
  VoidCallback? onMessageTap,
}) {
  return ProfileActionBar(
    status: status,
    notifier: notifier,
    isLoading: isLoading,
    userName: userName ?? "User",
    profilePicUrl: profilePicUrl,
    onMessageTap: onMessageTap,
  );
}

class ProfileActionBar extends StatelessWidget {
  final RelationshipStatus status;
  final UserRelationshipNotifier notifier;
  final bool isLoading;
  final String userName;
  final String? profilePicUrl;
  final VoidCallback? onMessageTap;

  const ProfileActionBar({
    super.key,
    required this.status,
    required this.notifier,
    required this.isLoading,
    this.userName = "User",
    this.profilePicUrl,
    this.onMessageTap,
  });

  void _showPendingOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _ActionBottomSheet(
          title: "Friend Request Sent",
          subtitle: "You sent a friend request to $userName",
          actions: [
            _BottomSheetActionItem(
              icon: LucideIcons.userX,
              title: "Cancel Friend Request",
              subtitle: "Cancel the pending request sent to $userName",
              iconBackgroundColor: DefaultColorSheet.white200,
              iconColor: DefaultColorSheet.grey500,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                notifier.removeFriendRequest();
              },
            ),
            _BottomSheetActionItem(
              icon: LucideIcons.ban,
              title: "Block $userName",
              subtitle: "They won't be able to find your profile or message you",
              isDestructive: true,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showBlockConfirmation(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showFriendsOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _ActionBottomSheet(
          title: "Manage Friendship",
          subtitle: "You and $userName are friends",
          actions: [
            if (onMessageTap != null)
              _BottomSheetActionItem(
                icon: LucideIcons.messageCircle,
                title: "Message $userName",
                subtitle: "Send a direct message",
                iconBackgroundColor: DefaultColorSheet.green100,
                iconColor: DefaultColorSheet.primary,
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  onMessageTap!();
                },
              ),
            _BottomSheetActionItem(
              icon: LucideIcons.userMinus,
              title: "Unfriend $userName",
              subtitle: "Remove $userName from your friends list",
              isDestructive: true,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showUnfriendConfirmation(context);
              },
            ),
            _BottomSheetActionItem(
              icon: LucideIcons.ban,
              title: "Block $userName",
              subtitle: "They won't be able to find your profile or message you",
              isDestructive: true,
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showBlockConfirmation(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showUnfriendConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: PrimaryText(
          "Unfriend $userName?",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: DefaultColorSheet.lightBlack,
        ),
        content: PrimaryText(
          "Are you sure you want to remove $userName from your friends list?",
          fontSize: 14,
          color: DefaultColorSheet.grey500,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const PrimaryText(
              "Cancel",
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DefaultColorSheet.grey500,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              notifier.removeFriendRequest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DefaultColorSheet.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const PrimaryText(
              "Unfriend",
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: PrimaryText(
          "Block $userName?",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: DefaultColorSheet.lightBlack,
        ),
        content: PrimaryText(
          "They won't be able to message you or view your profile. You can unblock them anytime.",
          fontSize: 14,
          color: DefaultColorSheet.grey500,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const PrimaryText(
              "Cancel",
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DefaultColorSheet.grey500,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              notifier.blockUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DefaultColorSheet.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const PrimaryText(
              "Block",
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _buildActionRow(context),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    switch (status) {
      case RelationshipStatus.none:
        return Row(
          children: [
            Expanded(
              child: _CustomProfileButton(
                onPressed: isLoading ? null : () => notifier.sendFriendRequest(),
                isLoading: isLoading,
                icon: LucideIcons.userPlus,
                label: "Add Friend",
                backgroundColor: DefaultColorSheet.primary,
                borderColor: DefaultColorSheet.primary,
                textColor: Colors.white,
              ),
            ),
          ],
        );

      case RelationshipStatus.pendingOutgoing:
        return Row(
          children: [
            Expanded(
              child: _CustomProfileButton(
                onPressed: isLoading ? null : () => _showPendingOptions(context),
                isLoading: isLoading,
                icon: LucideIcons.clock,
                label: "Requested",
                trailingIcon: LucideIcons.chevronDown,
                backgroundColor: DefaultColorSheet.green200,
                borderColor: DefaultColorSheet.grey100,
                textColor: Colors.white,
              ),
            ),
          ],
        );

      case RelationshipStatus.pendingIncoming:
        return Row(
          children: [
            Expanded(
              child: _CustomProfileButton(
                onPressed: isLoading ? null : () => notifier.acceptFriendRequest(),
                isLoading: isLoading,
                icon: LucideIcons.check,
                label: "Confirm",
                backgroundColor: DefaultColorSheet.primary,
                borderColor: DefaultColorSheet.primary,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CustomProfileButton(
                onPressed: isLoading ? null : () => notifier.rejectFriendRequest(),
                icon: LucideIcons.x,
                label: "Delete",
                backgroundColor: DefaultColorSheet.green200,
                borderColor: DefaultColorSheet.error.withValues(alpha: 0.5),
                textColor: DefaultColorSheet.error,
              ),
            ),
          ],
        );

      case RelationshipStatus.friends:
        return Row(
          children: [
            Expanded(
              child: _CustomProfileButton(
                onPressed: isLoading ? null : () => _showFriendsOptions(context),
                isLoading: isLoading,
                icon: LucideIcons.userCheck,
                iconColor: DefaultColorSheet.activeGreen,
                label: "Friends",
                trailingIcon: LucideIcons.chevronDown,
                backgroundColor: DefaultColorSheet.green200,
                borderColor: DefaultColorSheet.grey100,
                textColor: Colors.white,
              ),
            ),
            if (onMessageTap != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _CustomProfileButton(
                  onPressed: onMessageTap,
                  icon: LucideIcons.messageCircle,
                  label: "Message",
                  backgroundColor: DefaultColorSheet.primary,
                  borderColor: DefaultColorSheet.primary,
                  textColor: Colors.white,
                ),
              ),
            ],
          ],
        );

      case RelationshipStatus.blocked:
        return Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: DefaultColorSheet.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: DefaultColorSheet.error.withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.ban,
                      size: 18,
                      color: DefaultColorSheet.error,
                    ),
                    SizedBox(width: 8),
                    PrimaryText(
                      "Blocked",
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: DefaultColorSheet.error,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _CustomProfileButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData icon;
  final Color? iconColor;
  final String label;
  final IconData? trailingIcon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _CustomProfileButton({
    required this.onPressed,
    this.isLoading = false,
    required this.icon,
    this.iconColor,
    required this.label,
    this.trailingIcon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? textColor;

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: effectiveIconColor),
                  const SizedBox(width: 8),
                  Flexible(
                    child: PrimaryText(
                      label,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      trailingIcon,
                      size: 16,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _ActionBottomSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<_BottomSheetActionItem> actions;

  const _ActionBottomSheet({
    required this.title,
    this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag handle matching PrimaryContainer
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DefaultColorSheet.grey400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryText(
              title,
              textAlign: TextAlign.center,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DefaultColorSheet.lightBlack,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              PrimaryText(
                subtitle!,
                textAlign: TextAlign.center,
                fontSize: 13,
                color: DefaultColorSheet.grey500,
              ),
            ],
            const SizedBox(height: 16),
            ...actions.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  item,
                  if (index < actions.length - 1)
                    Divider(
                      height: 1,
                      color: DefaultColorSheet.grey100,
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const _BottomSheetActionItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDestructive ? DefaultColorSheet.error : DefaultColorSheet.lightBlack;
    final effectiveIconColor = isDestructive
        ? DefaultColorSheet.error
        : (iconColor ?? DefaultColorSheet.grey500);
    final effectiveIconBg = isDestructive
        ? DefaultColorSheet.error.withValues(alpha: 0.1)
        : (iconBackgroundColor ?? const Color(0xFFF2F7F6));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: effectiveIconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: effectiveIconColor),
      ),
      title: PrimaryText(
        title,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: titleColor,
      ),
      subtitle: subtitle == null
          ? null
          : PrimaryText(
              subtitle!,
              fontSize: 12,
              color: DefaultColorSheet.grey500,
            ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: DefaultColorSheet.grey400,
      ),
    );
  }
}
