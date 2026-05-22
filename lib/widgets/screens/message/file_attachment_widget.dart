import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/providers/media_download_provider.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:open_filex/open_filex.dart';

class FileAttachmentWidget extends ConsumerWidget {
  final MediaTableData media;

  const FileAttachmentWidget({super.key, required this.media});

  String _getFileIcon(String? contentType) {
    if (contentType?.contains('pdf') ?? false) return '📄';
    if (contentType?.contains('word') ?? false) return '📝';
    if (contentType?.contains('sheet') ?? false) return '📊';
    if (contentType?.contains('audio') ?? false) return '🎵';
    return '📎';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileExists =
        media.location != null && File(media.location!).existsSync();
    final downloadStates = ref.watch(mediaDownloadProvider);
    final downloadState = downloadStates[media.id];

    return GestureDetector(
      onTap: () async {
        if (fileExists) {
          await OpenFilex.open(media.location!);
        } else if (downloadState?.status != DownloadStatus.downloading) {
          ref.read(mediaDownloadProvider.notifier).downloadMedia(media);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFileIcon(media.contentType),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryText(
                    media.name ?? 'File',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  PrimaryText(
                    fileExists
                        ? 'Downloaded'
                        : (media.contentType ?? 'Unknown'),
                    fontSize: 10,
                    color: fileExists ? DefaultColorSheet.primary : Colors.grey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildActionIcon(fileExists, downloadState),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(bool fileExists, DownloadState? state) {
    if (fileExists) {
      return const Icon(
        LucideIcons.circleCheck,
        size: 16,
        color: DefaultColorSheet.primary,
      );
    }

    if (state == null || state.status == DownloadStatus.pending) {
      return Icon(LucideIcons.download, size: 16, color: Colors.grey[600]);
    }

    switch (state.status) {
      case DownloadStatus.downloading:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            value: state.progress,
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(
              DefaultColorSheet.primary,
            ),
          ),
        );
      case DownloadStatus.completed:
        return const Icon(
          LucideIcons.circleCheck,
          size: 16,
          color: DefaultColorSheet.primary,
        );
      case DownloadStatus.failed:
        return const Icon(
          LucideIcons.rotateCcw,
          size: 16,
          color: Colors.redAccent,
        );
      default:
        return Icon(LucideIcons.download, size: 16, color: Colors.grey[600]);
    }
  }
}
