import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/data/daos/recent_searches_dao.dart';
import 'package:my_app/providers/database_provider.dart';

final recentSearchesProvider = Provider<RecentSearchesDao>((ref) {
  final db = ref.watch(databaseProvider);
  return RecentSearchesDao(db);
});
