import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class DividerText extends StatelessWidget {
  final String text;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Color lineColor;
  final double lineThickness;
  final double spacing;

  const DividerText({
    super.key,
    required this.text,
    this.textColor = DefaultColorSheet.grey200,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.lineColor = DefaultColorSheet.grey100,
    this.lineThickness = 1,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: lineColor, thickness: lineThickness),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: lineColor, thickness: lineThickness),
        ),
      ],
    );
  }
}
