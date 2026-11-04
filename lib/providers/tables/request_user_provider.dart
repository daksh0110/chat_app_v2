import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/blocks_table_provider.dart';
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

    final isBlocked = await ref
        .read(blocksTableProvider.notifier)
        .isUserBlocked(userId);

    if (isBlocked) {
      return RelationshipStatus.blocked;
    }

    final friendRow = await (db.select(
      db.friendsTable,
    )..where((t) => t.userId.equals(userId))).getSingleOrNull();

    if (friendRow == null) {
      return RelationshipStatus.none;
    }

    return parseStatus(friendRow.status, isBlocked: isBlocked);
  }

  static RelationshipStatus parseStatus(String? status, {bool isBlocked = false}) {
    if (isBlocked) return RelationshipStatus.blocked;
    if (status == null) return RelationshipStatus.none;
    switch (status.toUpperCase()) {
      case 'PENDING_OUTGOING':
      case 'PENDING_OUTCOMING':
      case 'PENDING':
        return RelationshipStatus.pendingOutgoing;
      case 'PENDING_INCOMING':
        return RelationshipStatus.pendingIncoming;
      case 'FRIENDS':
      case 'ACCEPTED':
        return RelationshipStatus.friends;
      case 'BLOCKED':
        return RelationshipStatus.blocked;
      default:
        return RelationshipStatus.none;
    }
  }
}
