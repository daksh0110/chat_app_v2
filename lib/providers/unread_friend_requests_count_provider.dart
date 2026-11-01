import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/database_provider.dart';

/// Streams the count of unread incoming friend requests (drives badge on bell icon).
final unreadFriendRequestsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.friendsTable)
        ..where(
          (t) =>
              t.status.equals('PENDING_INCOMING') &
              t.isRead.equals(false),
        ))
      .watch()
      .map((rows) => rows.length);
});
