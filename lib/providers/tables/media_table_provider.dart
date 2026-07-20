import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/file_service.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/providers/database_provider.dart';

final mediaTableProvider = NotifierProvider<MediaTableProvider, void>(
  MediaTableProvider.new,
);

class MediaTableProvider extends Notifier {
  @override
  build() {}

  Future<UploadAttachment> addOrUpdateMediaDocument(
    UploadAttachment media,
    String actorId,
  ) async {
    final db = ref.read(databaseProvider);

    String? localPath = media.location;

    if (media.key.isNotEmpty) {
      final uploadService = UploadService(ApiClient());
      final fileService = FileService();

      final downloadUrl = await uploadService.resolveDownloadUrl(media);

      localPath = await fileService.downloadAndSave(
        downloadUrl: downloadUrl,
        actorId: actorId,
        media: media,
      );
    }

    final existing = await db.managers.mediaTable
        .filter((f) => f.actorId.equals(actorId))
        .getSingleOrNull();

    if (existing == null) {
      await db
          .into(db.mediaTable)
          .insert(
            MediaTableCompanion.insert(
              actorId: Value(actorId),
              key: Value(media.key),
              contentType: Value(media.contentType),
              Type: Value(media.type),
              location: Value(localPath),
              name: Value(media.name),
              createdAt: DateTime.now().millisecondsSinceEpoch,
              url: Value(media.url),
            ),
          );
    } else {
      await (db.update(
        db.mediaTable,
      )..where((t) => t.id.equals(existing.id))).write(
        MediaTableCompanion(
          key: Value(media.key),
          contentType: Value(media.contentType),
          Type: Value(media.type),
          location: Value(localPath),
          name: Value(media.name),
          url: Value(media.url),
        ),
      );
    }

    return UploadAttachment(
      key: media.key,
      contentType: media.contentType,
      type: media.type,
      name: media.name,
      url: media.url,
      location: localPath,
    );
  }

  Future<UploadAttachment?> getMediaByActorId(String actorId) async {
    final db = ref.read(databaseProvider);

    final media = await (db.select(
      db.mediaTable,
    )..where((t) => t.actorId.equals(actorId))).getSingleOrNull();

    if (media == null) {
      return null;
    }

    return UploadAttachment(
      key: media.key ?? "",
      contentType: media.contentType ?? "",
      type: media.Type ?? "",
      location: media.location ?? "",
      name: media.name ?? "",
    );
  }

  Future<void> bulkAddMediaDocuments(
    List<UploadAttachment> medias,
    String actorId,
  ) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.managers.mediaTable.bulkCreate(
      (o) => medias.map((media) {
        return o(
          actorId: Value(actorId),
          key: Value(media.key),
          contentType: Value(media.contentType),
          Type: Value(media.type),
          location: Value(media.location),
          name: Value(media.name),
          createdAt: now,
          url: Value(media.url),
        );
      }).toList(),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> updateActorId(String oldActorId, String newActorId) async {
    final db = ref.read(databaseProvider);

    await (db.update(db.mediaTable)..where((t) => t.actorId.equals(oldActorId)))
        .write(MediaTableCompanion(actorId: Value(newActorId)));
  }

  Future<void> updateUploadedMedia(
    String actorId,
    List<UploadAttachment> attachments,
  ) async {
    final db = ref.read(databaseProvider);

    if (attachments.isEmpty) return;

    final localMedias = await (db.select(
      db.mediaTable,
    )..where((t) => t.actorId.equals(actorId))).get();

    for (int i = 0; i < localMedias.length && i < attachments.length; i++) {
      final att = attachments[i];

      await (db.update(db.mediaTable)
            ..where((t) => t.id.equals(localMedias[i].id)))
          .write(MediaTableCompanion(key: Value(att.key), url: Value(att.url)));
    }
  }
}
