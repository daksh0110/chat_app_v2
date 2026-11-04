import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class DateBanner extends StatelessWidget {
  final String label;

  const DateBanner({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: DefaultColorSheet.bannerBg(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: DefaultColorSheet.bannerText(context),
          ),
        ),
      ),
    );
  }
}
