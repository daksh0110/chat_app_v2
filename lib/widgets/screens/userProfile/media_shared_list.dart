import 'package:flutter/material.dart';
import 'package:my_app/modal/user_profile_modal.dart';
import 'package:my_app/widgets/screens/userProfile/media_shared.dart';

class MediaSharedList extends StatelessWidget {
  const MediaSharedList({super.key, required this.media});

  final List<MediaShared> media;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          return MediaSharedComponent(sharedMedia: media[index]);
        },
      ),
    );
  }
}
