import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

enum MessageAlignment { left, center, right }

class MessageBubble extends StatelessWidget {
  final Widget child;
  final MessageAlignment alignment;
  final bool isGrouped;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final double? maxWidthFactor;

  const MessageBubble({
    super.key,
    required this.child,
    required this.alignment,
    this.isGrouped = false,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.maxWidthFactor,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == MessageAlignment.left;
    final isRight = alignment == MessageAlignment.right;

    return Align(
      alignment: switch (alignment) {
        MessageAlignment.left => Alignment.centerLeft,
        MessageAlignment.center => Alignment.center,
        MessageAlignment.right => Alignment.centerRight,
      },
      child: Container(
        margin: margin ?? EdgeInsets.fromLTRB(12, isGrouped ? 1 : 4, 12, 0),
        padding: padding ?? const EdgeInsets.fromLTRB(10, 8, 10, 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * (maxWidthFactor ?? .7),
        ),
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (isRight
                  ? DefaultColorSheet.green500
                  : isLeft
                  ? const Color(0xFFF2F7FB)
                  : Colors.transparent),
          borderRadius:
              borderRadius ??
              BorderRadius.only(
                topLeft: Radius.circular(isRight ? 16 : 0),
                topRight: Radius.circular(isLeft ? 16 : 0),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
        ),
        child: child,
      ),
    );
  }
}
