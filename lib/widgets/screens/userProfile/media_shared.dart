import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/modal/user_profile_modal.dart';

class MediaSharedComponent extends StatelessWidget {
  const MediaSharedComponent({super.key, required this.sharedMedia});

  final MediaShared sharedMedia;

  @override
  Widget build(BuildContext context) {
    switch (sharedMedia.type) {
      case "IMAGE":
        if (sharedMedia.location == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: 120,
          height: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(sharedMedia.location!), fit: BoxFit.cover),
          ),
        );

      case "VIDEO":
        return _mediaPlaceholder(icon: LucideIcons.play, label: "Video");

      case "FILE":
        return _mediaPlaceholder(
          icon: LucideIcons.file,
          label: sharedMedia.name,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _mediaPlaceholder({required IconData icon, required String label}) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
