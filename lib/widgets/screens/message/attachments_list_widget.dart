import 'package:flutter/material.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/widgets/screens/message/file_attachment_widget.dart';
import 'package:my_app/widgets/screens/message/image_attachment_widget.dart';
import 'package:my_app/widgets/screens/message/video_attachment_widget.dart';

class AttachmentsListWidget extends StatelessWidget {
  final List<MediaTableData> attachments;
  final String senderName;
  final int sentAt;

  const AttachmentsListWidget({
    super.key,
    required this.attachments,
    required this.senderName,
    required this.sentAt,
  });

  bool _isImage(String? contentType) {
    return contentType?.startsWith('image/') ?? false;
  }

  bool _isVideo(String? contentType) {
    return contentType?.startsWith('video/') ?? false;
  }

  Widget _buildMediaItem(MediaTableData media) {
    return SizedBox.expand(
      child: _isImage(media.contentType)
          ? ImageAttachmentWidget(
              media: media,
              senderName: senderName,
              sentAt: sentAt,
            )
          : VideoAttachmentWidget(
              media: media,
              senderName: senderName,
              sentAt: sentAt,
            ),
    );
  }

  Widget _buildMediaGrid(List<MediaTableData> mediaList) {
    if (mediaList.isEmpty) return const SizedBox.shrink();

    if (mediaList.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: _buildMediaItem(mediaList.first),
        ),
      );
    }

    if (mediaList.length == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: _buildMediaItem(mediaList[0]),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: _buildMediaItem(mediaList[1]),
              ),
            ),
          ],
        ),
      );
    }

    if (mediaList.length == 3) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              Expanded(flex: 2, child: _buildMediaItem(mediaList[0])),
              const SizedBox(height: 2),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildMediaItem(mediaList[1])),
                    const SizedBox(width: 2),
                    Expanded(child: _buildMediaItem(mediaList[2])),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4 or more
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1,
          ),
          itemCount: mediaList.length > 4 ? 4 : mediaList.length,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == 3 && mediaList.length > 4) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildMediaItem(mediaList[3]),
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        '+${mediaList.length - 4}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return _buildMediaItem(mediaList[index]);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final mediaList = attachments
        .where((m) => _isImage(m.contentType) || _isVideo(m.contentType))
        .toList();
    final fileList = attachments
        .where((m) => !_isImage(m.contentType) && !_isVideo(m.contentType))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mediaList.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: _buildMediaGrid(mediaList),
          ),
        if (mediaList.isNotEmpty && fileList.isNotEmpty)
          const SizedBox(height: 8),
        ...fileList.map(
          (media) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: FileAttachmentWidget(media: media),
          ),
        ),
      ],
    );
  }
}
