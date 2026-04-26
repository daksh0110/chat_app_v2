import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';

class SearchGroupItem extends StatelessWidget {
  final SearchItem item;
  final VoidCallback? onTap;
  final double height;
  final double chatBubbleSize;
  final bool needActiveIndicator;
  final List<Widget>? actionWidget;

  const SearchGroupItem({
    super.key,
    required this.item,
    this.onTap,
    this.height = 52,
    this.chatBubbleSize = 52,
    this.needActiveIndicator = false,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            UserBubble(
              profilePicUrl: item.profilePicUrl,
              size: 46,
              needActiveIndicator: needActiveIndicator,
              name: item.name,
            ),

            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                PrimaryText(
                  item.name,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  PrimaryText(
                    item.subtitle,
                    fontSize: 12,
                    color: DefaultColorSheet.grey500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            ...[
              if (actionWidget != null) ...[
                const SizedBox(width: 10),
                ...actionWidget!,
              ],
            ],
          ],
        ),
      ),
    );
  }
}
