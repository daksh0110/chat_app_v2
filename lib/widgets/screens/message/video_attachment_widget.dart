import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/providers/media_download_provider.dart';
import 'package:my_app/widgets/screens/message/media_viewer_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoAttachmentWidget extends ConsumerWidget {
  final MediaTableData media;
  final String senderName;
  final int sentAt;

  const VideoAttachmentWidget({
    super.key,
    required this.media,
    required this.senderName,
    required this.sentAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileExists =
        media.location != null && File(media.location!).existsSync();

    if (fileExists) {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MediaViewerScreen(
              media: media,
              senderName: senderName,
              sentAt: sentAt,
            ),
          ),
        ),
        child: _VideoThumbnail(path: media.location!),
      );
    }

    final downloadStates = ref.watch(mediaDownloadProvider);
    final downloadState = downloadStates[media.id];

    return GestureDetector(
      onTap: () {
        if (downloadState?.status != DownloadStatus.downloading) {
          ref.read(mediaDownloadProvider.notifier).downloadMedia(media);
        }
      },
      child: Container(
        color: const Color(0xFF222222),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.video, size: 34, color: Colors.white38),
                SizedBox(height: 8),
                Text(
                  'Video',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: _buildDownloadIndicator(downloadState),
            ),
            const Positioned(
              bottom: 8,
              child: Text(
                'Tap to download',
                style: TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadIndicator(DownloadState? state) {
    if (state == null || state.status == DownloadStatus.pending) {
      return const Icon(LucideIcons.download, color: Colors.white, size: 20);
    }

    switch (state.status) {
      case DownloadStatus.downloading:
        return Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: state.progress,
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            Text(
              '${(state.progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      case DownloadStatus.completed:
        return const Icon(LucideIcons.check, color: Colors.white, size: 20);
      case DownloadStatus.failed:
        return const Icon(
          LucideIcons.rotateCcw,
          color: Colors.redAccent,
          size: 20,
        );
      default:
        return const Icon(LucideIcons.download, color: Colors.white, size: 20);
    }
  }
}

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        FutureBuilder<Uint8List?>(
          future: VideoThumbnail.thumbnailData(
            video: path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 500,
            quality: 80,
          ),
          builder: (context, snapshot) => snapshot.hasData
              ? Image.memory(snapshot.data!, fit: BoxFit.cover)
              : const ColoredBox(color: Color(0xFF222222)),
        ),
        Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.play, color: Colors.white, size: 25),
          ),
        ),
      ],
    );
  }
}
