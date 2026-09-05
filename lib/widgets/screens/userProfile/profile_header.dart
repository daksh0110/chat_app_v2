import 'package:flutter/material.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    this.profilePicUrl,
    this.subtitle,
  });

  final String name;
  final String? profilePicUrl;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        UserBubble(
          profilePicUrl: profilePicUrl,
          name: name,
          size: 80,
          needActiveIndicator: false,
        ),
        const SizedBox(height: 10),
        PrimaryText(
          name,
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          PrimaryText(subtitle!, color: Colors.white70, fontSize: 14),
        ],
      ],
    );
  }
}
