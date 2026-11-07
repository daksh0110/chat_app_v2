import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ChatSettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const ChatSettingsSection({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: PrimaryText(
              title!,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DefaultColorSheet.textSecondary(context),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: DefaultColorSheet.cardBg(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: DefaultColorSheet.divider(context),
              width: 0.8,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: children,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

