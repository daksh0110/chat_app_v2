import 'dart:io';

import 'package:flutter/material.dart';

class ProfileImagePreview extends StatelessWidget {
  const ProfileImagePreview({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              child: Image.file(File(imagePath), fit: BoxFit.contain),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
