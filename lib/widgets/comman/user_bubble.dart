import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class UserBubble extends StatelessWidget {
  const UserBubble({
    super.key,
    required this.profilePic,
    this.size = 52,
    this.needActiveIndicator = false,
  });

  final String profilePic;
  final double size;
  final bool needActiveIndicator;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: Image.asset(
            profilePic,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),

        if (needActiveIndicator)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: DefaultColorSheet.activeGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
