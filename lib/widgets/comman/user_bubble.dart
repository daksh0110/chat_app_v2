import 'package:flutter/material.dart';

class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.profilePic});
  final String profilePic;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(profilePic, width: 52, height: 52, fit: BoxFit.cover),
    );
  }
}
