import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AttachmentPopover extends StatelessWidget {
  const AttachmentPopover({super.key, this.onTap});

  final Function(String key)? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(LucideIcons.image),
            title: const Text('Gallery'),
            key: const Key("gallery"),
            onTap: () {
              onTap?.call("gallery");
              Navigator.pop(context);

              // handle photo
            },
          ),

          ListTile(
            leading: const Icon(LucideIcons.video),
            title: const Text('Video'),
            key: const Key("video"),
            onTap: () {
              Navigator.pop(context);
              onTap?.call("video");
            },
          ),

          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text('File'),
            key: const Key("file"),
            onTap: () {
              Navigator.pop(context);
              onTap?.call("file");
            },
          ),
        ],
      ),
    );
  }
}
