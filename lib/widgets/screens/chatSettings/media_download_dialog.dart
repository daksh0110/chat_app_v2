import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class MediaDownloadDialog extends StatelessWidget {
  final String currentSetting;
  final ValueChanged<String> onSettingSelected;

  const MediaDownloadDialog({
    super.key,
    required this.currentSetting,
    required this.onSettingSelected,
  });

  static const List<Map<String, String>> options = [
    {
      'title': 'Default',
      'value': 'default',
      'subtitle': 'Download photos over Wi-Fi only'
    },
    {
      'title': 'Wi-Fi only',
      'value': 'wifi_only',
      'subtitle': 'Never auto-download on cellular data'
    },
    {
      'title': 'Always (Wi-Fi & Cellular)',
      'value': 'always',
      'subtitle': 'Automatically download all received media'
    },
    {
      'title': 'Never',
      'value': 'never',
      'subtitle': 'Manually tap to download each photo/video'
    },
  ];

  static Future<void> show(
    BuildContext context, {
    required String currentSetting,
    required ValueChanged<String> onSettingSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: DefaultColorSheet.containerBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => MediaDownloadDialog(
        currentSetting: currentSetting,
        onSettingSelected: onSettingSelected,
      ),
    );
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
          PrimaryText(
            'Media Auto-Download',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DefaultColorSheet.textPrimary(context),
          ),
          const SizedBox(height: 14),
          ...options.map((opt) {
            final val = opt['value']!;
            final isSelected = currentSetting == val;

            return InkWell(
              onTap: () {
                onSettingSelected(val);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PrimaryText(
                            opt['title']!,
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: DefaultColorSheet.textPrimary(context),
                          ),
                          const SizedBox(height: 2),
                          PrimaryText(
                            opt['subtitle']!,
                            fontSize: 12,
                            color: DefaultColorSheet.textSecondary(context),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: DefaultColorSheet.primary,
                        size: 22,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

