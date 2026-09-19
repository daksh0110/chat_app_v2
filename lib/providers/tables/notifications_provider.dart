import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/notification_model.dart';
import 'package:my_app/providers/database_provider.dart';

final notificationTableProvider = NotifierProvider<NotificationsProvider, void>(
  NotificationsProvider.new,
);

class NotificationsProvider extends Notifier<void> {
  @override
  void build() {}

  Future<void> createOrUpdateNotification(
    NotificationModel notification,
  ) async {
    final db = ref.read(databaseProvider);

    await db
        .into(db.notificationsTable)
        .insertOnConflictUpdate(
          NotificationsTableCompanion(
            id: Value(notification.id),
            recipientId: Value(notification.recipientId),
            actorId: Value(notification.actorId),
            type: Value(notification.type.name),
            entityId: Value(notification.entityId),
            entityType: Value(notification.entityType?.name),
            isRead: Value(notification.isRead),
            readAt: Value(notification.isRead ? notification.createdAt : null),
            createdAt: Value(notification.createdAt),
          ),
        );
  }

  Stream<List<NotificationsTableData>> watchNotifications(String recipientId) {
    final db = ref.read(databaseProvider);

    return (db.select(db.notificationsTable)
          ..where((table) => table.recipientId.equals(recipientId))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .watch();
  }

  Future<void> markAsRead(String notificationId) async {
    final db = ref.read(databaseProvider);

    await (db.update(
      db.notificationsTable,
    )..where((table) => table.id.equals(notificationId))).write(
      NotificationsTableCompanion(
        isRead: const Value(true),
        readAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markAllAsRead(String recipientId) async {
    final db = ref.read(databaseProvider);

    await (db.update(db.notificationsTable)..where(
          (table) =>
              table.recipientId.equals(recipientId) &
              table.isRead.equals(false),
        ))
        .write(
          NotificationsTableCompanion(
            isRead: const Value(true),
            readAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> updateFriendRequestNotification({
    required String recipientId,
    required String actorId,
    required NotificationType type,
  }) async {
    final db = ref.read(databaseProvider);

    final notification =
        await (db.select(db.notificationsTable)
              ..where(
                (table) =>
                    table.recipientId.equals(recipientId) &
                    table.actorId.equals(actorId) &
                    table.type.equals(
                      NotificationType.friendRequestReceived.name,
                    ),
              )
              ..orderBy([(table) => OrderingTerm.desc(table.createdAt)])
              ..limit(1))
            .getSingleOrNull();

    if (notification == null) return;

    await (db.update(
      db.notificationsTable,
    )..where((table) => table.id.equals(notification.id))).write(
      NotificationsTableCompanion(
        type: Value(type.name),
        isRead: const Value(true),
        readAt: Value(DateTime.now()),
      ),
    );
  }
}
