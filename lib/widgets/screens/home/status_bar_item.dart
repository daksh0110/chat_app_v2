import 'package:flutter/material.dart';
import 'package:my_app/modal/status_bar_modal.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class StatusBarItem extends StatelessWidget {
  const StatusBarItem({super.key, required this.item, this.isMe = false});

  final StatusBarModal item;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            item.profileUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 6),
        PrimaryText(isMe ? "My Status" : item.name, color: Colors.white),
      ],
    );
  }
}
