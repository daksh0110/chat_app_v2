import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/token_provider.dart';

/// Model for a single incoming friend request or friendship notification row
/// (joined from FriendsTable + UsersTable + MediaTable)
class FriendRequestNotification {
  final String userId;
  final String name;
  final String? email;
  final String? bio;
  final String? localMediaPath;
  final String status;
  final bool isRead;

  const FriendRequestNotification({
    required this.userId,
    required this.name,
    this.email,
    this.bio,
    this.localMediaPath,
    required this.status,
    required this.isRead,
  });
}

/// Live stream of friend request / friendship notifications (status = PENDING_INCOMING or FRIENDS).
/// Joined with UsersTable (name/bio/email) and MediaTable (local avatar path).
/// Unread rows come first.
final friendRequestsProvider = StreamProvider.autoDispose<
    List<FriendRequestNotification>>((ref) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.friendsTable).join([
    leftOuterJoin(
      db.usersTable,
      db.usersTable.userId.equalsExp(db.friendsTable.userId),
    ),
    leftOuterJoin(
      db.mediaTable,
      db.mediaTable.actorId.equalsExp(db.friendsTable.userId),
    ),
  ])
    ..where(db.friendsTable.status.isIn(['PENDING_INCOMING', 'FRIENDS']))
    ..orderBy([
      OrderingTerm(
        expression: db.friendsTable.isRead,
        mode: OrderingMode.asc, // unread (false) first
      ),
    ]);

  return query.watch().map((rows) {
    return rows.map((row) {
      final friend = row.readTable(db.friendsTable);
      final user = row.readTableOrNull(db.usersTable);
      final media = row.readTableOrNull(db.mediaTable);

      return FriendRequestNotification(
        userId: friend.userId,
        name: user?.name ?? friend.userId,
        email: user?.email,
        bio: user?.bio,
        localMediaPath: media?.location,
        status: friend.status,
        isRead: friend.isRead,
      );
    }).toList();
  });
});

/// Syncs all user relationships (FRIENDS, PENDING_INCOMING, PENDING_OUTGOING, BLOCKED) from REST on login/startup.
Future<void> syncRelationshipsFromRest(WidgetRef ref) async {
  try {
    final token = await ref.read(tokenProvider.future);
    if (token == null) return;
    final response =
        await UserApiService(ApiClient()).getAllRelationships(token: token);
    final items = response.data ?? [];
    final db = ref.read(databaseProvider);

    for (final item in items) {
      final existing = await (db.select(db.friendsTable)
            ..where((t) => t.userId.equals(item.id)))
          .getSingleOrNull();

      final status = item.relationshipStatus ?? 'NONE';

      await db.into(db.friendsTable).insertOnConflictUpdate(
            FriendsTableCompanion(
              userId: Value(item.id),
              status: Value(status),
              isRead: Value(existing?.isRead ?? true),
            ),
          );
      await db.into(db.usersTable).insertOnConflictUpdate(
            UsersTableCompanion(
              userId: Value(item.id),
              name: Value(item.name),
              email: Value(item.email ?? ''),
              bio: Value(item.bio ?? ''),
            ),
          );
    }
  } catch (_) {}
}

Future<void> seedFriendRequestsFromRest(WidgetRef ref) async {
  return syncRelationshipsFromRest(ref);
}
