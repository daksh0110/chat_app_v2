import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class SocialIconButton extends StatelessWidget {
  final String assetPath;
  final double size;
  final double padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const SocialIconButton({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.padding = 10,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(48),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: borderColor ?? DefaultColorSheet.grey300),
        ),
        child: SvgPicture.asset(assetPath, width: size, height: size),
      ),
    );
  }
}
