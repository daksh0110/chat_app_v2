import 'package:drift/drift.dart';

class ChatSettingsTable extends Table {
  TextColumn get chatId => text()();
  BoolColumn get isMuted => boolean().withDefault(const Constant(false))();
  IntColumn get mutedUntil => integer().nullable()();
  TextColumn get notificationSound =>
      text().withDefault(const Constant('default'))();
  TextColumn get wallpaper => text().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get pinnedAt => integer().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get archivedAt => integer().nullable()();
  IntColumn get disappearingDuration =>
      integer().withDefault(const Constant(0))();
  TextColumn get mediaAutoDownload =>
      text().withDefault(const Constant('default'))();

  @override
  Set<Column> get primaryKey => {chatId};
}
