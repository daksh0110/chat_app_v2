import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/screens/settings/blocked_user_model.dart';
import 'package:my_app/providers/database_provider.dart';

final blocksTableProvider = NotifierProvider<BlocksTableProvider, void>(
  BlocksTableProvider.new,
);

final blockedUsersProvider = StreamProvider<List<BlockedUserModel>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.blocksTable).join([
    leftOuterJoin(
      db.usersTable,
      db.usersTable.userId.equalsExp(db.blocksTable.userId),
    ),
    leftOuterJoin(
      db.mediaTable,
      db.mediaTable.actorId.equalsExp(db.blocksTable.userId),
    ),
  ])..orderBy([OrderingTerm.desc(db.blocksTable.createdAt)]);

  return query.watch().map((rows) {
    return rows.map((row) {
      final block = row.readTable(db.blocksTable);
      final user = row.readTableOrNull(db.usersTable);
      final media = row.readTableOrNull(db.mediaTable);

      return BlockedUserModel(
        userId: block.userId,
        name: user?.name ?? "User",
        email: user?.email,
        bio: user?.bio,
        profilePicUrl: media?.location,
        blockedAt: block.createdAt ?? DateTime.now(),
      );
    }).toList();
  });
});

class BlocksTableProvider extends Notifier<void> {
  @override
  void build() {}

  Future<void> blockUser(String userId) async {
    final db = ref.read(databaseProvider);
    await db
        .into(db.blocksTable)
        .insertOnConflictUpdate(
          BlocksTableCompanion(
            userId: Value(userId),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> unblockUser(String userId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(
      db.blocksTable,
    )..where((t) => t.userId.equals(userId))).go();
  }

  Future<bool> isUserBlocked(String userId) async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(
      db.blocksTable,
    )..where((t) => t.userId.equals(userId))).getSingleOrNull();
    return row != null;
  }

  Stream<bool> watchIsUserBlocked(String userId) {
    final db = ref.read(databaseProvider);
    return (db.select(db.blocksTable)..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull()
        .map((row) => row != null);
  }

  Future<List<String>> getBlockedUserIds() async {
    final db = ref.read(databaseProvider);
    final rows = await db.select(db.blocksTable).get();
    return rows.map((r) => r.userId).toList();
  }

  Stream<List<String>> watchBlockedUserIds() {
    final db = ref.read(databaseProvider);
    return db
        .select(db.blocksTable)
        .watch()
        .map((rows) => rows.map((r) => r.userId).toList());
  }

  Future<void> clearAllBlocks() async {
    final db = ref.read(databaseProvider);
    await db.delete(db.blocksTable).go();
  }
}
