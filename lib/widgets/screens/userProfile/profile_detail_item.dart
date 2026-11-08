import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ProfileDetailItem extends StatelessWidget {
  final String title;
  final String value;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onEdit;

  const ProfileDetailItem({
    super.key,
    required this.title,
    required this.value,
    this.padding,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryText(
          title,
          color: DefaultColorSheet.textSecondary(context),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        const SizedBox(height: 5),
        PrimaryText(
          value,
          color: DefaultColorSheet.textPrimary(context),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ],
    );

    if (onEdit != null) {
      content = InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 22),
      child: content,
    );
  }
}
