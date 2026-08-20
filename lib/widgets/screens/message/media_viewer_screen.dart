import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/core/database.dart';
import 'package:video_player/video_player.dart';

/// Full-screen image and video viewer used by chat media attachments.
class MediaViewerScreen extends StatelessWidget {
  const MediaViewerScreen({
    super.key,
    required this.media,
    required this.senderName,
    required this.sentAt,
  });

  final MediaTableData media;
  final String senderName;
  final int sentAt;

  bool get _isVideo => media.contentType?.startsWith('video/') ?? false;

  @override
  Widget build(BuildContext context) {
    final path = media.location;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1F8E6D),
              child: Text(
                senderName.isEmpty ? '?' : senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    senderName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    DateFormat(
                      'd MMM, hh:mm a',
                    ).format(DateTime.fromMillisecondsSinceEpoch(sentAt)),
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: path == null || !File(path).existsSync()
          ? const Center(
              child: Text(
                'This media is no longer available',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : _isVideo
          ? _FullscreenVideo(path: path)
          : InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Center(child: Image.file(File(path), fit: BoxFit.contain)),
            ),
    );
  }
}

class _FullscreenVideo extends StatefulWidget {
  const _FullscreenVideo({required this.path});

  final String path;

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  late final VideoPlayerController _controller;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
        }
      })
      ..addListener(_onVideoChanged);
  }

  void _onVideoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onVideoChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final position = _controller.value.position;
    final duration = _controller.value.duration;
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : position.inMilliseconds / duration.inMilliseconds;

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          if (_showControls) ...[
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: () => _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play(),
              icon: Icon(
                _controller.value.isPlaying
                    ? LucideIcons.pause
                    : LucideIcons.play,
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 24,
              child: Row(
                children: [
                  Text(
                    _format(position),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  Expanded(
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      activeColor: const Color(0xFF1F9D78),
                      onChanged: (value) => _controller.seekTo(
                        Duration(
                          milliseconds: (duration.inMilliseconds * value)
                              .round(),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _format(duration),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _format(Duration value) =>
      '${value.inMinutes.remainder(60).toString().padLeft(2, '0')}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}
