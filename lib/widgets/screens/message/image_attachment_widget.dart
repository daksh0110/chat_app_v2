import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/providers/media_download_provider.dart';

class ImageAttachmentWidget extends ConsumerWidget {
  final MediaTableData media;

  const ImageAttachmentWidget({super.key, required this.media});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileExists = media.location != null && File(media.location!).existsSync();

    if (fileExists) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () {
            // TODO: Open full screen image viewer
          },
          child: Image.file(
            File(media.location!),
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.imageOff, size: 32, color: Colors.grey),
                    SizedBox(height: 4),
                    Text('Image not found', style: TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    final downloadStates = ref.watch(mediaDownloadProvider);
    final downloadState = downloadStates[media.id];

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GestureDetector(
        onTap: () {
          if (downloadState?.status != DownloadStatus.downloading) {
            ref.read(mediaDownloadProvider.notifier).downloadMedia(media);
          }
        },
        child: Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                LucideIcons.image,
                size: 48,
                color: Colors.white24,
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: _buildDownloadIndicator(downloadState),
              ),
              if (media.name != null)
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  child: Text(
                    media.name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadIndicator(DownloadState? state) {
    if (state == null || state.status == DownloadStatus.pending) {
      return const Icon(
        LucideIcons.download,
        color: Colors.white,
        size: 20,
      );
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
        return const Icon(
          LucideIcons.check,
          color: Colors.white,
          size: 20,
        );
      case DownloadStatus.failed:
        return const Icon(
          LucideIcons.rotateCcw,
          color: Colors.redAccent,
          size: 20,
        );
      default:
        return const Icon(
          LucideIcons.download,
          color: Colors.white,
          size: 20,
        );
    }
  }
}
