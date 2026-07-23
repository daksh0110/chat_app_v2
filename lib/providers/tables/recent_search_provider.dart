import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';

final recentSearchProvider = NotifierProvider<RecentSearchProvider, void>(
  RecentSearchProvider.new,
);

class RecentSearchProvider extends Notifier {
  @override
  build() {}

  Stream<List<SearchItem>> getRecentSearches() {
    debugPrint("Fetching recent searches");
    final db = ref.read(databaseProvider);
    final query = db.select(db.recentSearchesTable).join([
      leftOuterJoin(
        db.groupListTable,
        db.groupListTable.chatId.equalsExp(db.recentSearchesTable.actorId),
      ),
      leftOuterJoin(
        db.usersTable,
        db.usersTable.userId.equalsExp(db.recentSearchesTable.actorId),
      ),
      leftOuterJoin(
        db.mediaTable,
        db.mediaTable.actorId.equalsExp(db.usersTable.userId),
      ),
    ]);

    return query.watch().map((rows) {
      debugPrint("Joined rows: ${rows.length}");

      return rows.map((row) {
        final recentSearch = row.readTable(db.recentSearchesTable);

        final user = row.readTableOrNull(db.usersTable);
        final group = row.readTableOrNull(db.groupListTable);
        final media = row.readTableOrNull(db.mediaTable);
        debugPrint(
          "Mapping recent search: actorId=${recentSearch.actorId}, actorType=${recentSearch.actorType}, user=${user?.name}, group=${group?.name}, media=${media?.location}, userID=${user?.userId}, groupID=${group?.chatId}",
        );
        if (recentSearch.actorType == 'USER') {
          return SearchItem(
            id: user!.userId,
            name: user.name,
            email: user.email,
            bio: user.bio,
            profilePicUrl: media?.location ?? '',
            actorType: recentSearch.actorType,
          );
        } else if (recentSearch.actorType == 'GROUP') {
          return SearchItem(
            id: group!.chatId,
            name: group.name,
            bio: group.bio ?? '',
            profilePicUrl: media?.location ?? '',
            actorType: recentSearch.actorType,
          );
        }
        return SearchItem(
          id: group?.chatId ?? user?.userId ?? '',
          name: group?.name ?? user?.name ?? '',
          bio: group?.bio ?? user?.bio ?? '',
          profilePicUrl: media?.location ?? '',
          actorType: "OTHER",
        );
      }).toList();
    });
  }

  Future<void> addRecentSearch(SearchItem searchItem) async {
    final db = ref.read(databaseProvider);
    final userTableRef = ref.read(usersTableProvider.notifier);
    await userTableRef.updateUserProfile(
      UserModel(
        id: searchItem.id,
        name: searchItem.name,
        email: searchItem.email ?? '',
        bio: searchItem.bio ?? '',
      ),
      searchItem.media,
    );

    final recentSearch = RecentSearchesTableCompanion(
      actorId: Value(searchItem.id),
      searchedAt: Value(DateTime.now().millisecondsSinceEpoch),
      actorType: Value(searchItem.actorType ?? ''),
    );
    await db
        .into(db.recentSearchesTable)
        .insert(recentSearch, mode: InsertMode.insertOrReplace);
  }

  Future<void> removeRecentSearch(String actorId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(
      db.recentSearchesTable,
    )..where((tbl) => tbl.actorId.equals(actorId))).go();
  }

  Future<void> clearRecentSearches() async {
    final db = ref.read(databaseProvider);
    await db.delete(db.recentSearchesTable).go();
  }
}
