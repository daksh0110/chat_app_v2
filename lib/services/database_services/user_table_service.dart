import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/providers/database_provider.dart';

Future<void> updateUserProfile(WidgetRef ref, SearchItem data) async {
  final db = ref.read(databaseProvider);

  await db.managers.userInfoSettings
      .filter((f) => f.id.equals(data.id))
      .update(
        (o) => o(
          bio: Value(data.bio),
          email: Value(data.email ?? ''),
          name: Value(data.name),
        ),
      );
}
