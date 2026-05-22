import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class InlineVideoPlayer extends StatefulWidget {
  final String path;

  const InlineVideoPlayer({super.key, required this.path});

  @override
  State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
  late VideoPlayerController controller;

  bool initialized = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.file(File(widget.path));

    controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          initialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Container(
        width: 200,
        height: 150,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          controller.value.isPlaying ? controller.pause() : controller.play();
        });
      },

      child: Stack(
        alignment: Alignment.center,

        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),

            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,

              child: VideoPlayer(controller),
            ),
          ),

          if (!controller.value.isPlaying)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}
