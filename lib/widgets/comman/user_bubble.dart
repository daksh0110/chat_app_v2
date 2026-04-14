import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class UserBubble extends StatelessWidget {
  const UserBubble({
    super.key,
    required this.profilePic,
    this.size = 52,
    this.needActiveIndicator = false,
    this.name = "",
  });

  final String profilePic;
  final double size;
  final bool needActiveIndicator;
  final String name;

  @override
  Widget build(BuildContext context) {
    final bool isValidUrl = Uri.tryParse(profilePic)?.hasAbsolutePath ?? false;
    final bool isAssetImage = !isValidUrl && profilePic.isNotEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: isValidUrl
              ? Image.network(
                  profilePic,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                )
              : isAssetImage
              ? Image.asset(
                  profilePic,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF075E54),
                    shape: BoxShape.circle,
                  ),
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  child: PrimaryText(
                    name.isNotEmpty ? name[0].toUpperCase() : "",
                    color: Colors.white,
                    fontSize: size * 0.5,
                  ),
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
