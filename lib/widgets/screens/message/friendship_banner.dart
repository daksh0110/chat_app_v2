import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/providers/user_relationship_provider.dart';

class FriendshipBanner extends ConsumerWidget {
  final String receiverId;
  final String name;
  final RelationshipStatus status;

  const FriendshipBanner({
    super.key,
    required this.receiverId,
    required this.name,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userRelationshipProvider(receiverId).notifier);
    final cardBg = DefaultColorSheet.cardBg(context);
    final textPrimary = DefaultColorSheet.textPrimary(context);
    final textSecondary = DefaultColorSheet.textSecondary(context);
    final isDark = DefaultColorSheet.isDark(context);

    switch (status) {
      case RelationshipStatus.none:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: DefaultColorSheet.accentGreen.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? DefaultColorSheet.accentGreen.withValues(alpha: 0.2)
                      : DefaultColorSheet.accentGreenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.userPlus,
                  size: 16,
                  color: DefaultColorSheet.accentGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$name is not in your friends",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => notifier.sendFriendRequest(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DefaultColorSheet.accentGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Add Friend",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case RelationshipStatus.pendingOutgoing:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.clock,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Friend request sent",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => notifier.removeFriendRequest(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? DefaultColorSheet.darkSurface
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? DefaultColorSheet.darkDivider
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case RelationshipStatus.pendingIncoming:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: DefaultColorSheet.accentGreen.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? DefaultColorSheet.accentGreen.withValues(alpha: 0.2)
                      : DefaultColorSheet.accentGreenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.userCheck,
                  size: 16,
                  color: DefaultColorSheet.accentGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$name sent you a friend request",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => notifier.acceptFriendRequest(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: DefaultColorSheet.accentGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => notifier.rejectFriendRequest(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? DefaultColorSheet.darkSurface
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case RelationshipStatus.friends:
      case RelationshipStatus.blocked:
        return const SizedBox.shrink();
    }
  }
}

