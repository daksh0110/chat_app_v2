import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/widgets/screens/search/search_group_item.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() {
    return _HeaderState();
  }
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: const Color(0x05111222),
      backgroundColor: Colors.white,
      title: SearchGroupItem(
        height: 48,
        chatBubbleSize: 44,
        needActiveIndicator: true,
        item: SearchItem(
          id: "1",
          name: "name",
          profilePic: "assets/screens/home/user1.png",
          subtitle: "active now",
        ),
      ),
      actionsPadding: EdgeInsets.fromLTRB(0, 0, 15, 0),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            LucideIcons.phone,
            color: DefaultColorSheet.lightBlack,
            size: 20,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            LucideIcons.video,
            color: DefaultColorSheet.lightBlack,
            size: 20,
          ),
        ),
      ],
    );
  }
}
