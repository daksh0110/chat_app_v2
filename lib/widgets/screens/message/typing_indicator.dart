import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class TypingIndicator extends StatefulWidget {
  @override
  State<TypingIndicator> createState() {
    return _TypingIndicatorState();
  }
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> dot1;
  late Animation<double> dot2;
  late Animation<double> dot3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    dot1 = _buildAnimation(0.0, 0.4);
    dot2 = _buildAnimation(0.2, 0.6);
    dot3 = _buildAnimation(0.4, 0.8);
  }

  Animation<double> _buildAnimation(double start, double end) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeInOut),
      ),
    );
  }

  Widget _dot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: DefaultColorSheet.grey500,
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: EdgeInsets.fromLTRB(10, 14, 10, 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F7FB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(dot1),
            const SizedBox(width: 4),
            _dot(dot2),
            const SizedBox(width: 4),
            _dot(dot3),
          ],
        ),
      ),
    );
  }
}
