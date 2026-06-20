import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/providers/database_provider.dart';

final userProvider = StreamProvider<SearchItem?>((ref) {
  final db = ref.read(databaseProvider);

  final query = db.select(db.userInfoSettings).join([
    leftOuterJoin(
      db.mediaTable,
      db.mediaTable.actorId.equalsExp(db.userInfoSettings.id),
    ),
  ]);

  return query.watch().map((rows) {
    if (rows.isEmpty) return null;

    final row = rows.first;

    final user = row.readTable(db.userInfoSettings);
    final media = row.readTableOrNull(db.mediaTable);

    return SearchItem(
      id: user.id,
      name: user.name,
      email: user.email,
      bio: user.bio,
      profilePicUrl: media?.location ?? user.profilePictureUrl,
    );
  });
});
