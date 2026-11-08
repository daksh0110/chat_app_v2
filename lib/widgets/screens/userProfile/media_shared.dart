import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/user_profile_modal.dart';
import 'package:my_app/widgets/screens/message/media_viewer_screen.dart';

class MediaSharedComponent extends StatelessWidget {
  const MediaSharedComponent({super.key, required this.sharedMedia});

  final MediaShared sharedMedia;

  void _openViewer(BuildContext context) {
    if (sharedMedia.location == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          media: MediaTableData(
            id: 0,
            location: sharedMedia.location,
            contentType: sharedMedia.contentType,
            actorId: sharedMedia.actorId,
            Type: sharedMedia.type,
            name: sharedMedia.name,
            key: sharedMedia.key,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
          senderName: sharedMedia.userName,
          sentAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (sharedMedia.type.toUpperCase()) {
      case "IMAGE":
        if (sharedMedia.location == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => _openViewer(context),
          child: SizedBox(
            width: 120,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(sharedMedia.location!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _mediaPlaceholder(context,
                        icon: LucideIcons.imageOff, label: sharedMedia.name),
              ),
            ),
          ),
        );

      case "VIDEO":
        return GestureDetector(
          onTap: () => _openViewer(context),
          child: _mediaPlaceholder(
            context,
            icon: LucideIcons.play,
            label: sharedMedia.name.isNotEmpty ? sharedMedia.name : "Video",
          ),
        );

      case "FILE":
        return _mediaPlaceholder(
          context,
          icon: LucideIcons.file,
          label: sharedMedia.name,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _mediaPlaceholder(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: DefaultColorSheet.inputFieldBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DefaultColorSheet.dividerColor(context),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: DefaultColorSheet.iconSecondary(context),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: DefaultColorSheet.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
