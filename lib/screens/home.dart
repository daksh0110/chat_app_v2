import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/data/dummy_chat_list.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/home/bottom_nav_item.dart';
import 'package:my_app/widgets/screens/home/chat_list_item.dart';
import 'package:my_app/widgets/screens/home/status_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int currentActive = 0;
  final List<ChatListModal> data = dummyChatListData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        actionsPadding: EdgeInsets.all(24),
        actions: [Image.asset("assets/screens/home/user1.png", height: 44)],
        backgroundColor: Colors.black,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/search");
              },
              icon: const Icon(Icons.search, color: Colors.white),
            );
          },
        ),

        centerTitle: true,
        title: PrimaryText("Home", fontSize: 20, color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadiusGeometry.directional(
                  topEnd: Radius.circular(40),
                  topStart: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Expanded(
                    child: ListView.separated(
                      itemCount: data.length,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemBuilder: (context, index) {
                        return ChatListItem(chat: data[index], onTap: () {});
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: DefaultColorSheet.primary, width: 0.4),
          ),
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Colors.white,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: BottomNavItem(
                    icon: LucideIcons.messageCircleMore300,
                    label: "Message",
                    isActive: currentActive == 0,
                    onTap: () {
                      setState(() {
                        currentActive = 0;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: BottomNavItem(
                    icon: LucideIcons.phone300,
                    label: "Calls",
                    isActive: currentActive == 1,
                    onTap: () {
                      setState(() {
                        currentActive = 1;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: BottomNavItem(
                    icon: LucideIcons.circleUserRound300,
                    label: "Contacts",
                    isActive: currentActive == 2,
                    onTap: () {
                      setState(() {
                        currentActive = 2;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: BottomNavItem(
                    icon: LucideIcons.settings300,
                    label: "Settings",
                    isActive: currentActive == 3,
                    onTap: () {
                      setState(() {
                        currentActive = 3;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
