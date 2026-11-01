import 'package:flutter/material.dart';
import 'package:my_app/widgets/comman/primary_container.dart';

class ProfileDetailsPanel extends StatelessWidget {
  const ProfileDetailsPanel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      children: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
