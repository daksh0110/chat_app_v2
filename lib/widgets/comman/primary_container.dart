import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class PrimaryContainer extends StatelessWidget {
  const PrimaryContainer({super.key, required this.children});

  final Widget children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColorSheet.containerBg(context),
        borderRadius: const BorderRadiusGeometry.directional(
          topEnd: Radius.circular(40),
          topStart: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DefaultColorSheet.isDark(context)
                  ? Colors.grey.shade700
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 5),
          Expanded(child: children),
        ],
      ),
    );
  }
}
