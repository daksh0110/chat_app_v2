import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A reusable action sheet for choosing the type of chat attachment.
class AttachmentBottomSheet extends StatelessWidget {
  const AttachmentBottomSheet({
    super.key,
    required this.onCamera,
    required this.onMedia,
    required this.onDocuments,
  });

  final VoidCallback onCamera;
  final VoidCallback onMedia;
  final VoidCallback onDocuments;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onMedia,
    required VoidCallback onDocuments,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AttachmentBottomSheet(
        onCamera: onCamera,
        onMedia: onMedia,
        onDocuments: onDocuments,
      ),
    );
  }

  void _select(BuildContext context, VoidCallback callback) {
    Navigator.of(context).pop();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 21),
                ),
                const Expanded(
                  child: Text(
                    'Share Content',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 10),
            _AttachmentAction(
              icon: LucideIcons.camera,
              title: 'Camera',
              onTap: () => _select(context, onCamera),
            ),
            const Divider(height: 1),
            _AttachmentAction(
              icon: LucideIcons.fileText,
              title: 'Documents',
              subtitle: 'Share your files',
              onTap: () => _select(context, onDocuments),
            ),
            const Divider(height: 1),
            _AttachmentAction(
              icon: LucideIcons.image,
              title: 'Media',
              subtitle: 'Share photos and videos',
              onTap: () => _select(context, onMedia),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      onTap: onTap,
      leading: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F7F6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 21, color: const Color(0xFF687672)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF7D8482)),
            ),
    );
  }
}
