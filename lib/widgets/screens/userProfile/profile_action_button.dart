import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;

  const ProfileActionButton({
    super.key,
    required this.icon,
    this.onTap,
    this.backgroundColor = DefaultColorSheet.green200,
    this.iconColor = Colors.white,
    this.size = 42,
    this.iconSize = 23,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}
