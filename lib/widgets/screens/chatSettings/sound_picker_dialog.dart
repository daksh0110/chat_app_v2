import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class SoundPickerDialog extends StatelessWidget {
  final String currentSound;
  final ValueChanged<String> onSoundSelected;

  const SoundPickerDialog({
    super.key,
    required this.currentSound,
    required this.onSoundSelected,
  });

  static const List<Map<String, String>> soundList = [
    {'name': 'Default', 'value': 'default'},
    {'name': 'Note', 'value': 'note'},
    {'name': 'Aurora', 'value': 'aurora'},
    {'name': 'Bamboo', 'value': 'bamboo'},
    {'name': 'Chord', 'value': 'chord'},
    {'name': 'Pop', 'value': 'pop'},
    {'name': 'Silent (None)', 'value': 'none'},
  ];

  static Future<void> show(
    BuildContext context, {
    required String currentSound,
    required ValueChanged<String> onSoundSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: DefaultColorSheet.containerBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SoundPickerDialog(
        currentSound: currentSound,
        onSoundSelected: onSoundSelected,
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
            'Notification Sound',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DefaultColorSheet.textPrimary(context),
          ),
          const SizedBox(height: 14),
          ...soundList.map((sound) {
            final val = sound['value']!;
            final isSelected = currentSound == val;

            return InkWell(
              onTap: () {
                onSoundSelected(val);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      val == 'none' ? Icons.notifications_off : Icons.music_note,
                      size: 20,
                      color: isSelected
                          ? DefaultColorSheet.primary
                          : DefaultColorSheet.textSecondary(context),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: PrimaryText(
                        sound['name']!,
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: DefaultColorSheet.textPrimary(context),
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

