import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/search/user_profile_arguments.dart';
import 'package:my_app/providers/friend_requests_provider.dart';
import 'package:my_app/providers/tables/request_user_provider.dart';
import 'package:my_app/providers/token_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all as read when screen opens — clears badge
    Future.microtask(() => _markAllRead());
  }

  Future<void> _markAllRead() async {
    final db = ref.read(databaseProvider);
    await (db.update(db.friendsTable)..where(
          (t) => t.status.equals('PENDING_INCOMING') & t.isRead.equals(false),
        ))
        .write(const FriendsTableCompanion(isRead: drift.Value(true)));
  }

  Future<void> _accept(FriendRequestNotification item) async {
    final token = ref.read(tokenProvider).value;
    if (token == null) return;
    try {
      final response = await UserApiService(
        ApiClient(),
      ).acceptFriendRequest(token: token, targetUserId: item.userId);

      if (!response.success) {
        throw Exception(response.message);
      }

      await ref
          .read(requestUserProvider.notifier)
          .insertOrUpdateRequest(item.userId, 'FRIENDS');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept: $e'),
          backgroundColor: DefaultColorSheet.red100,
        ),
      );
    }
  }

  Future<void> _reject(FriendRequestNotification item) async {
    final token = ref.read(tokenProvider).value;
    if (token == null) return;
    try {
      final response = await UserApiService(
        ApiClient(),
      ).rejectFriendRequest(token: token, targetUserId: item.userId);

      if (!response.success) {
        throw Exception(response.message);
      }

      await ref
          .read(requestUserProvider.notifier)
          .insertOrUpdateRequest(item.userId, 'NONE');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject: $e'),
          backgroundColor: DefaultColorSheet.red100,
        ),
      );
    }
  }

  void _navigateToProfile(FriendRequestNotification item) {
    Navigator.pushNamed(
      context,
      AppRoutes.userProfile,
      arguments: UserProfileArguments(
        id: item.userId,
        name: item.name,
        profilePicUrl: item.localMediaPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(friendRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: DefaultColorSheet.lightBlack,
            size: 20,
          ),
        ),
        title: const PrimaryText(
          'Notifications',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DefaultColorSheet.lightBlack,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: DefaultColorSheet.grey200),
        ),
      ),
      body: requestsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: DefaultColorSheet.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.circleAlert,
                size: 48,
                color: DefaultColorSheet.grey400,
              ),
              const SizedBox(height: 12),
              PrimaryText(
                e.toString(),
                color: DefaultColorSheet.grey500,
                fontSize: 13,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: DefaultColorSheet.green100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.bell,
                      size: 48,
                      color: DefaultColorSheet.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const PrimaryText(
                    'No new notifications',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DefaultColorSheet.lightBlack,
                  ),
                  const SizedBox(height: 8),
                  const PrimaryText(
                    'Friend requests will appear here.',
                    fontSize: 13,
                    color: DefaultColorSheet.grey500,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: requests.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 80,
              color: DefaultColorSheet.grey200,
            ),
            itemBuilder: (context, index) {
              final item = requests[index];
              return _FriendRequestTile(
                item: item,
                onTap: () => _navigateToProfile(item),
                onAccept: () => _accept(item),
                onReject: () => _reject(item),
              );
            },
          );
        },
      ),
    );
  }
}

class _FriendRequestTile extends StatelessWidget {
  const _FriendRequestTile({
    required this.item,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  final FriendRequestNotification item;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final hasLocalFile =
        item.localMediaPath != null && File(item.localMediaPath!).existsSync();
    final isFriends = item.status == 'FRIENDS';

    return Material(
      color: item.isRead ? Colors.transparent : DefaultColorSheet.white100,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              UserBubble(
                profilePicUrl: hasLocalFile ? item.localMediaPath : null,
                name: item.name,
                size: 52,
                needActiveIndicator: false,
              ),

              const SizedBox(width: 14),

              // Name + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryText(
                            item.name,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: DefaultColorSheet.lightBlack,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: DefaultColorSheet.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (isFriends) ...[
                          const Icon(
                            LucideIcons.userCheck,
                            size: 13,
                            color: DefaultColorSheet.primary,
                          ),
                          const SizedBox(width: 4),
                          const PrimaryText(
                            'You both are friends',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: DefaultColorSheet.primary,
                          ),
                        ] else ...[
                          const PrimaryText(
                            'Sent you a friend request',
                            fontSize: 12,
                            color: DefaultColorSheet.grey500,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Actions or Chevron for accepted
              if (isFriends)
                const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: DefaultColorSheet.grey400,
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Reject
                    GestureDetector(
                      onTap: onReject,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: DefaultColorSheet.grey200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          size: 18,
                          color: DefaultColorSheet.grey500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Accept
                    GestureDetector(
                      onTap: onAccept,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: DefaultColorSheet.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.check,
                          size: 18,
                          color: Colors.white,
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
