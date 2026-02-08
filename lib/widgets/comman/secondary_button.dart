import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final String? fontFamily;
  final EdgeInsetsGeometry padding;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 48,
    this.borderRadius = 16,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black,
    this.textColor = Colors.black,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.fontFamily,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: fontFamily,
          ),
        ),
      ),
    );
  }
}
