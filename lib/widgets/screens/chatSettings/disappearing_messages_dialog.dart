import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class DisappearingMessagesDialog extends StatelessWidget {
  final int currentDuration;
  final ValueChanged<int> onDurationSelected;

  const DisappearingMessagesDialog({
    super.key,
    required this.currentDuration,
    required this.onDurationSelected,
  });

  static const List<Map<String, dynamic>> options = [
    {'title': 'Off', 'duration': 0, 'subtitle': 'Messages will not disappear'},
    {'title': '24 Hours', 'duration': 86400, 'subtitle': '1 day'},
    {'title': '7 Days', 'duration': 604800, 'subtitle': '1 week'},
    {'title': '90 Days', 'duration': 7776000, 'subtitle': 'About 3 months'},
  ];

  static Future<void> show(
    BuildContext context, {
    required int currentDuration,
    required ValueChanged<int> onDurationSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: DefaultColorSheet.containerBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DisappearingMessagesDialog(
        currentDuration: currentDuration,
        onDurationSelected: onDurationSelected,
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
            'Disappearing Messages',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DefaultColorSheet.textPrimary(context),
          ),
          const SizedBox(height: 6),
          PrimaryText(
            'When turned on, new messages sent in this chat will disappear after the selected duration.',
            fontSize: 13,
            color: DefaultColorSheet.textSecondary(context),
          ),
          const SizedBox(height: 16),
          ...options.map((opt) {
            final duration = opt['duration'] as int;
            final isSelected = currentDuration == duration;

            return InkWell(
              onTap: () {
                onDurationSelected(duration);
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
                            opt['title'] as String,
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: DefaultColorSheet.textPrimary(context),
                          ),
                          const SizedBox(height: 2),
                          PrimaryText(
                            opt['subtitle'] as String,
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

