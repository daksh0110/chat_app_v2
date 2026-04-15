import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/widgets/screens/search/search_group_item.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({
    super.key,
    required this.name,
    required this.id,
    required this.isOnline,
    this.profilePic,
  });

  final String name;
  final String id;
  final bool isOnline;
  final String? profilePic;

  @override
  Size get preferredSize {
    // default fallback
    return const Size.fromHeight(kToolbarHeight);
  }

  @override
  State<StatefulWidget> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  double getToolbarHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenHeight < 600) {
      return 48;
    } else if (screenHeight < 750) {
      return 52;
    } else {
      return 56;
    }
  }

  @override
  Widget build(BuildContext context) {
    final toolbarHeight = getToolbarHeight(context);

    return AppBar(
      toolbarHeight: toolbarHeight,
      shadowColor: const Color(0x05111222),
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0.0,
      title: SearchGroupItem(
        height: toolbarHeight - 8,
        chatBubbleSize: toolbarHeight - 12,
        needActiveIndicator: widget.isOnline,
        item: SearchItem(
          id: widget.id,
          name: widget.name,
          profilePic: "assets/no-image-icon.jpg",
          subtitle: widget.isOnline ? "active now" : "",
          profilePicUrl: widget.profilePic,
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 15),
      actions: const [
        Icon(LucideIcons.phone, color: DefaultColorSheet.lightBlack, size: 20),
        SizedBox(width: 10),
        Icon(LucideIcons.video, color: DefaultColorSheet.lightBlack, size: 20),
      ],
    );
  }
}
