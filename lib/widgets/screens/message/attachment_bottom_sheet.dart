import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

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
        decoration: BoxDecoration(
          color: DefaultColorSheet.surfaceBg(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    LucideIcons.x,
                    size: 21,
                    color: DefaultColorSheet.iconColor(context),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Share Content',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: DefaultColorSheet.textPrimary(context),
                    ),
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
            Divider(
              height: 1,
              color: DefaultColorSheet.divider(context),
            ),
            _AttachmentAction(
              icon: LucideIcons.fileText,
              title: 'Documents',
              subtitle: 'Share your files',
              onTap: () => _select(context, onDocuments),
            ),
            Divider(
              height: 1,
              color: DefaultColorSheet.divider(context),
            ),
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
    final iconBg = DefaultColorSheet.inputFieldBg(context);
    final iconColor = DefaultColorSheet.iconSecondary(context);
    final titleColor = DefaultColorSheet.textPrimary(context);
    final subtitleColor = DefaultColorSheet.textSecondary(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      onTap: onTap,
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: iconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 21, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
    );
  }
}
