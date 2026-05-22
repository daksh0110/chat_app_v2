import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:my_app/core/database.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/core/network/api_client.dart';

enum DownloadStatus { pending, downloading, completed, failed }

class DownloadState {
  final DownloadStatus status;
  final double progress;
  final String? localPath;
  final String? errorMessage;

  DownloadState({
    required this.status,
    this.progress = 0.0,
    this.localPath,
    this.errorMessage,
  });
}

final mediaDownloadProvider =
    NotifierProvider<MediaDownloadNotifier, Map<int, DownloadState>>(
      MediaDownloadNotifier.new,
    );

class MediaDownloadNotifier extends Notifier<Map<int, DownloadState>> {
  @override
  Map<int, DownloadState> build() {
    return {};
  }

  Future<void> downloadMedia(MediaTableData media) async {
    final mediaId = media.id;
    
    // Avoid downloading if already downloading or completed
    if (state[mediaId]?.status == DownloadStatus.downloading) return;
    if (state[mediaId]?.status == DownloadStatus.completed) return;

    state = {
      ...state,
      mediaId: DownloadState(status: DownloadStatus.downloading, progress: 0.0),
    };

    try {
      final db = ref.read(databaseProvider);
      
      // Get download URL
      String? downloadUrl = media.url;
      final key = media.key;

      if (key == null || key.isEmpty) {
        throw Exception("No key available for this media");
      }

      // If URL is missing, get a fresh one
      if (downloadUrl == null || downloadUrl.isEmpty) {
        final uploadService = UploadService(ApiClient());
        final res = await uploadService.getDownloadUrl(key);
        if (res.success && res.data != null) {
          downloadUrl = res.data;
          await db.managers.mediaTable
              .filter((f) => f.id.equals(mediaId))
              .update((o) => o(url: Value(downloadUrl)));
        } else {
          throw Exception("Failed to get download URL: ${res.message}");
        }
      }

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(downloadUrl!));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          // Token expired or URL expired, request a fresh one
          final uploadService = UploadService(ApiClient());
          final res = await uploadService.getDownloadUrl(key);
          if (res.success && res.data != null) {
            downloadUrl = res.data;
            await db.managers.mediaTable
                .filter((f) => f.id.equals(mediaId))
                .update((o) => o(url: Value(downloadUrl)));
            
            final retryRequest = http.Request('GET', Uri.parse(downloadUrl!));
            final retryResponse = await client.send(retryRequest);
            if (retryResponse.statusCode == 200) {
              await _saveResponseToFile(retryResponse, media);
              return;
            }
          }
        }
        throw Exception("Server returned status ${response.statusCode}");
      }

      await _saveResponseToFile(response, media);
    } catch (e) {
      state = {
        ...state,
        mediaId: DownloadState(
          status: DownloadStatus.failed,
          errorMessage: e.toString(),
        ),
      };
    }
  }

  Future<void> _saveResponseToFile(http.StreamedResponse response, MediaTableData media) async {
    final mediaId = media.id;
    final db = ref.read(databaseProvider);
    final totalBytes = response.contentLength ?? 0;
    int receivedBytes = 0;

    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${appDir.path}/attachments');
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    final extension = p.extension(media.name ?? '');
    final filename = '${media.key?.replaceAll('/', '_') ?? media.id.toString()}$extension';
    final localFile = File('${attachmentsDir.path}/$filename');

    final sink = localFile.openWrite();
    
    try {
      await response.stream.listen(
        (chunk) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0) {
            final progress = receivedBytes / totalBytes;
            state = {
              ...state,
              mediaId: DownloadState(
                status: DownloadStatus.downloading,
                progress: progress,
              ),
            };
          }
        },
        onError: (e) async {
          await sink.close();
          throw e;
        },
        cancelOnError: true,
      ).asFuture();

      await sink.close();

      // Update Drift DB
      await db.managers.mediaTable
          .filter((f) => f.id.equals(mediaId))
          .update((o) => o(location: Value(localFile.path)));

      state = {
        ...state,
        mediaId: DownloadState(
          status: DownloadStatus.completed,
          localPath: localFile.path,
          progress: 1.0,
        ),
      };
    } catch (e) {
      if (await localFile.exists()) {
        await localFile.delete();
      }
      rethrow;
    }
  }
}
