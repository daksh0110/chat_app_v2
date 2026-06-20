import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/providers/database_provider.dart';

Future<UploadAttachment> addOrUpdateMediaDocument(
  UploadAttachment media,
  WidgetRef ref,
  String actorId,
) async {
  final db = ref.read(databaseProvider);

  final existing = await db.managers.mediaTable
      .filter((f) => f.actorId.equals(actorId))
      .getSingleOrNull();

  if (existing == null) {
    await db
        .into(db.mediaTable)
        .insertOnConflictUpdate(
          MediaTableCompanion(
            actorId: Value(actorId),
            key: Value(media.key),
            contentType: Value(media.contentType),
            Type: Value(media.type),
            location: Value(media.location),
            name: Value(media.name),
            createdAt: Value(DateTime.now().microsecondsSinceEpoch),
          ),
        );
  } else {
    await db
        .into(db.mediaTable)
        .insertOnConflictUpdate(
          existing.copyWith(
            key: Value(media.key),
            contentType: Value(media.contentType),
            Type: Value(media.type),
            location: Value(media.location),
            name: Value(media.name),
          ),
        );
  }

  return media;
}
