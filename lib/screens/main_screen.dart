import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/data/navigation_menu.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/screens/homescreen.dart';
import 'package:my_app/screens/settings/settings_main.dart';
import 'package:my_app/widgets/screens/home/bottom_nav_item.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int currentActive = 0;
  final List<ChatListModal> data = [];

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      Homescreen(data: data),
      // const Center(
      //   child: Text("Calls Screen", style: TextStyle(color: Colors.white)),
      // ),
      // const SettingsMain(),
      const SettingsMain(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = menu[currentActive];
    final selectedList = ref.watch(selectedChatListProvider);
    final isSelectionActive = selectedList.isNotEmpty;

    return PopScope(
      canPop: !isSelectionActive,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        if (isSelectionActive) {
          ref.read(selectedChatListProvider.notifier).clearList();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: currentItem.appBar(context),
        body: screens[currentActive],
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(
                menu.length,
                (index) => Expanded(
                  child: BottomNavItem(
                    icon: menu[index].icon,
                    label: menu[index].label,
                    isActive: currentActive == index,
                    onTap: () {
                      setState(() {
                        currentActive = index;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
