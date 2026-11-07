import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class WallpaperPickerDialog extends StatelessWidget {
  final String? currentWallpaper;
  final ValueChanged<String?> onWallpaperSelected;

  const WallpaperPickerDialog({
    super.key,
    required this.currentWallpaper,
    required this.onWallpaperSelected,
  });

  static const List<Map<String, String>> presetWallpapers = [
    {'name': 'Default', 'value': ''},
    {'name': 'Classic Warm', 'value': '0xFFECE5DD'},
    {'name': 'Dark Slate', 'value': '0xFF111B21'},
    {'name': 'Midnight Navy', 'value': '0xFF0A192F'},
    {'name': 'Forest Emerald', 'value': '0xFF0B2B26'},
    {'name': 'Charcoal', 'value': '0xFF1E293B'},
    {'name': 'Lavender Mist', 'value': '0xFFF3E8FF'},
    {'name': 'Soft Sage', 'value': '0xFFE2E8F0'},
  ];

  static Future<void> show(
    BuildContext context, {
    required String? currentWallpaper,
    required ValueChanged<String?> onWallpaperSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: DefaultColorSheet.containerBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => WallpaperPickerDialog(
        currentWallpaper: currentWallpaper,
        onWallpaperSelected: onWallpaperSelected,
      ),
    );
  }

  Future<void> _pickCustomImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked != null && context.mounted) {
        onWallpaperSelected(picked.path);
        Navigator.pop(context);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              PrimaryText(
                'Chat Wallpaper',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DefaultColorSheet.textPrimary(context),
              ),
              const Spacer(),
              if (currentWallpaper != null && currentWallpaper!.isNotEmpty)
                TextButton(
                  onPressed: () {
                    onWallpaperSelected(null);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Reset Default',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Gallery Image Option
          InkWell(
            onTap: () => _pickCustomImage(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DefaultColorSheet.cardBg(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: DefaultColorSheet.divider(context),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DefaultColorSheet.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.image,
                      color: DefaultColorSheet.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PrimaryText(
                          'Choose from Photos',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: DefaultColorSheet.textPrimary(context),
                        ),
                        PrimaryText(
                          'Set an image from your device gallery',
                          fontSize: 12,
                          color: DefaultColorSheet.textSecondary(context),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          PrimaryText(
            'Preset Colors',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DefaultColorSheet.textSecondary(context),
          ),
          const SizedBox(height: 12),

          // Presets Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presetWallpapers.map((preset) {
              final val = preset['value']!;
              final isSelected = (currentWallpaper == null || currentWallpaper!.isEmpty)
                  ? val.isEmpty
                  : currentWallpaper == val;

              Color previewColor;
              if (val.isEmpty) {
                previewColor = DefaultColorSheet.isDark(context)
                    ? const Color(0xFF0F141A)
                    : const Color(0xFFECE5DD);
              } else {
                final intVal = int.tryParse(val) ?? 0xFFECE5DD;
                previewColor = Color(intVal);
              }

              return InkWell(
                onTap: () {
                  onWallpaperSelected(val.isEmpty ? null : val);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: previewColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? DefaultColorSheet.primary
                              : Colors.grey.shade400,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Icon(
                                Icons.check_circle,
                                color: previewColor.computeLuminance() > 0.5
                                    ? Colors.black87
                                    : Colors.white,
                                size: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 64,
                      child: Text(
                        preset['name']!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? DefaultColorSheet.primary
                              : DefaultColorSheet.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

