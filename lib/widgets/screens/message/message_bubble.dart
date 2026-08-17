import 'package:flutter/material.dart';

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
    final resolvedColor =
        backgroundColor ??
        (isRight
            ? const Color(0xFFDCF8C6)
            : isLeft
            ? Colors.white
            : Colors.transparent);
    final isMediaOnly = resolvedColor == Colors.transparent;

    // Tail-style border radius: small nub on the "sender" corner
    final resolvedRadius =
        borderRadius ??
        BorderRadius.only(
          topLeft: Radius.circular(isRight ? 18 : (isGrouped ? 18 : 4)),
          topRight: Radius.circular(isLeft ? 18 : (isGrouped ? 18 : 4)),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        );

    return Align(
      alignment: switch (alignment) {
        MessageAlignment.left => Alignment.centerLeft,
        MessageAlignment.center => Alignment.center,
        MessageAlignment.right => Alignment.centerRight,
      },
      child: Container(
        margin:
            margin ??
            EdgeInsets.fromLTRB(
              isLeft ? 8 : 60,
              isGrouped ? 1 : 3,
              isRight ? 8 : 60,
              0,
            ),
        padding: padding ?? const EdgeInsets.fromLTRB(10, 7, 10, 7),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * (maxWidthFactor ?? .75),
        ),
        decoration: BoxDecoration(
          color: resolvedColor,
          boxShadow: isMediaOnly
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
          borderRadius: resolvedRadius,
        ),
        child: child,
      ),
    );
  }
}
