import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';

final databaseProvider = Provider((ref) {
  return AppDatabase();
});
