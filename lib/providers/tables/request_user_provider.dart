import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/user_relationship_provider.dart';

final requestUserProvider = NotifierProvider<RequestUserProvider, void>(
  RequestUserProvider.new,
);

class RequestUserProvider extends Notifier {
  @override
  build() {}

  Future<void> insertOrUpdateRequest(
    String userId,
    String status, {
    bool isRead = true,
  }) async {
    final db = ref.read(databaseProvider);
    await db
        .into(db.friendsTable)
        .insertOnConflictUpdate(
          FriendsTableCompanion(
            userId: Value(userId),
            status: Value(status),
            isRead: Value(isRead),
          ),
        );
  }

  Future<RelationshipStatus> getRelationshipStatus(String userId) async {
    final db = ref.read(databaseProvider);

    final friendRow = await (db.select(
      db.friendsTable,
    )..where((t) => t.userId.equals(userId))).getSingleOrNull();

    if (friendRow == null) {
      return RelationshipStatus.none;
    }

    switch (friendRow.status) {
      case 'PENDING_OUTGOING':
        return RelationshipStatus.pendingOutgoing;
      case 'PENDING_INCOMING':
        return RelationshipStatus.pendingIncoming;
      case 'PENDING':
        return RelationshipStatus.pendingOutgoing;
      case 'FRIENDS':
        return RelationshipStatus.friends;
      case 'BLOCKED':
        return RelationshipStatus.blocked;
      default:
        return RelationshipStatus.none;
    }
  }
}
