import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ProfileDetailItem extends StatelessWidget {
  final String title;
  final String value;
  final EdgeInsetsGeometry? padding;

  const ProfileDetailItem({
    super.key,
    required this.title,
    required this.value,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimaryText(
            title,
            color: DefaultColorSheet.grey500,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          const SizedBox(height: 5),
          PrimaryText(
            value,
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
