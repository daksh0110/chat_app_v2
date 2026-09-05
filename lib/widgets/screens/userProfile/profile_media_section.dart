import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/user_profile_modal.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/userProfile/media_shared_list.dart';

class ProfileMediaSection extends StatelessWidget {
  const ProfileMediaSection({
    super.key,
    required this.media,
    required this.totalMediaCount,
  });

  final List<MediaShared> media;
  final int totalMediaCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const PrimaryText(
              'Media Shared',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: DefaultColorSheet.grey500,
            ),
            const Spacer(),
            PrimaryText(
              totalMediaCount > media.length
                  ? 'View all ($totalMediaCount)'
                  : 'View all',
              color: DefaultColorSheet.green500,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        if (media.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: PrimaryText('No media found', textAlign: TextAlign.center),
          )
        else ...[
          const SizedBox(height: 12),
          MediaSharedList(media: media),
        ],
      ],
    );
  }
}
