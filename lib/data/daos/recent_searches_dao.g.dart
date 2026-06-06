part of 'recent_searches_dao.dart';

mixin _$RecentSearchesDaoMixin on DatabaseAccessor<AppDatabase> {
  $RecentSearchesTableTable get recentSearchesTable =>
      attachedDatabase.recentSearchesTable;
  RecentSearchesDaoManager get managers => RecentSearchesDaoManager(this);
}

class RecentSearchesDaoManager {
  final _$RecentSearchesDaoMixin _db;
  RecentSearchesDaoManager(this._db);
  $$RecentSearchesTableTableTableManager get recentSearchesTable =>
      $$RecentSearchesTableTableTableManager(
        _db.attachedDatabase,
        _db.recentSearchesTable,
      );
}
