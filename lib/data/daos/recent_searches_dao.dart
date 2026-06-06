import 'package:drift/drift.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/tables/recent_searches_table.dart';

part 'recent_searches_dao.g.dart';

@DriftAccessor(tables: [RecentSearchesTable])
class RecentSearchesDao extends DatabaseAccessor<AppDatabase> with _$RecentSearchesDaoMixin {
  RecentSearchesDao(super.db);

  Future<void> upsertRecentSearch({
    required String userId,
    required String name,
    required String email,
    String? profilePicUrl,
  }) async {
    await into(recentSearchesTable).insertOnConflictUpdate(
      RecentSearchesTableCompanion.insert(
        userId: userId,
        name: name,
        email: Value(email),
        profilePicUrl: Value(profilePicUrl),
        searchedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Stream<List<RecentSearchesTableData>> watchRecentSearches({int limit = 20}) {
    return (select(recentSearchesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
          ..limit(limit))
        .watch();
  }

  Future<void> deleteRecentSearch(String userId) async {
    await (delete(recentSearchesTable)
          ..where((t) => t.userId.equals(userId)))
        .go();
  }
}
