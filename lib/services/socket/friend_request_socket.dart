import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/friend_request_received_modal.dart';
import 'package:my_app/modal/notification_model.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/providers/tables/notifications_provider.dart';
import 'package:my_app/providers/tables/request_user_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:uuid/uuid.dart';

final friendRequestSocketProvider =
    NotifierProvider<FriendRequestSocketNotifier, void>(
      FriendRequestSocketNotifier.new,
    );

class FriendRequestSocketNotifier extends Notifier<void> {
  @override
  void build() {}

  void listen() {
    final socketService = ref.read(socketProvider);

    // Live incoming friend request
    socketService.listen('friend_request_received', (data) async {
      final friendRequest = FriendRequestModal.fromJson(data);
      debugPrint(friendRequest.toString());
      await ref
          .read(usersTableProvider.notifier)
          .fetchAndUpdateUserProfile(friendRequest.requesterId);
      await ref
          .read(requestUserProvider.notifier)
          .insertOrUpdateRequest(
            friendRequest.requesterId,
            "PENDING_INCOMING",
            isRead: false,
          );
      await _saveNotification(
        actorId: friendRequest.requesterId,
        type: NotificationType.friendRequestReceived,
      );
    });

    socketService.listen('friend_request_accepted', (data) async {
      final accepterId = data['accepter_id'] as String;

      await ref
          .read(requestUserProvider.notifier)
          .insertOrUpdateRequest(accepterId, "FRIENDS");

      await ref
          .read(usersTableProvider.notifier)
          .fetchAndUpdateUserProfile(accepterId);
      await _saveNotification(
        actorId: accepterId,
        type: NotificationType.friendRequestAccepted,
      );
    });

    socketService.listen('friend_request_rejected', (data) async {
      final rejecterId = data['rejecter_id'] as String;

      await ref
          .read(requestUserProvider.notifier)
          .insertOrUpdateRequest(rejecterId, 'NONE');
    });

    // Friend removed
    socketService.listenOnce('friend_removed', (data) async {
      final userId = data['remover_id'] as String;

      await ref
          .read(requestUserProvider.notifier)
          .insertOrUpdateRequest(userId, 'NONE');
    });

    socketService.listen('relationship_sync', (data) async {
      try {
        if (data is List) {
          final db = ref.read(databaseProvider);
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              final searchItem = SearchItem.fromJson(item);
              final status = searchItem.relationshipStatus ?? 'NONE';

              if (status == 'BLOCKED') {
                await db
                    .into(db.blocksTable)
                    .insertOnConflictUpdate(
                      BlocksTableCompanion(
                        userId: Value(searchItem.id),
                        createdAt: Value(DateTime.now()),
                      ),
                    );
              } else {
                await (db.delete(
                  db.blocksTable,
                )..where((t) => t.userId.equals(searchItem.id))).go();

                final existing =
                    await (db.select(db.friendsTable)
                          ..where((t) => t.userId.equals(searchItem.id)))
                        .getSingleOrNull();

                await db
                    .into(db.friendsTable)
                    .insertOnConflictUpdate(
                      FriendsTableCompanion(
                        userId: Value(searchItem.id),
                        status: Value(status),
                        isRead: Value(existing?.isRead ?? true),
                      ),
                    );
              }

              await db
                  .into(db.usersTable)
                  .insertOnConflictUpdate(
                    UsersTableCompanion(
                      userId: Value(searchItem.id),
                      name: Value(searchItem.name),
                      email: Value(searchItem.email ?? ''),
                      bio: Value(searchItem.bio ?? ''),
                    ),
                  );
            }
          }
        }
      } catch (_) {}
    });
  }

  Future<void> _saveNotification({
    required String actorId,
    required NotificationType type,
  }) async {
    final recipientId = ref.read(userPreferenceTableProvider).value;
    if (recipientId == null) return;

    await ref
        .read(notificationTableProvider.notifier)
        .createOrUpdateNotification(
          NotificationModel(
            id: const Uuid().v4(),
            recipientId: recipientId,
            actorId: actorId,
            type: type,
            entityId: actorId,
            entityType: NotificationEntityType.user,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
  }
}
