import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/data/navigation_menu.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/screens/homescreen.dart';
import 'package:my_app/screens/settings/settings_main.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/home/bottom_nav_item.dart';
import 'package:drift/drift.dart' hide Column;

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int currentActive = 0;
  final List<ChatListModal> data = [];
  final flipKey = GlobalKey<FlipCardState>();
  late List<String> selectedList;
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

  void onDelete() async {
    final db = ref.read(databaseProvider);
    await db.managers.messages
        .filter((f) => f.chatId.isIn(selectedList))
        .delete();
    await db.managers.chatListTable
        .filter((f) => f.chatId.isIn(selectedList))
        .update((o) => o(isDeleted: const Value(true)));
    ref.read(selectedChatListProvider.notifier).clearList();
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = menu[currentActive];
    selectedList = ref.watch(selectedChatListProvider);
    final isSelectionActive = selectedList.isNotEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedList.isNotEmpty && (flipKey.currentState?.isFront ?? true)) {
        flipKey.currentState?.toggleCard();
      } else if (selectedList.isEmpty &&
          !(flipKey.currentState?.isFront ?? false)) {
        flipKey.currentState?.toggleCard();
      }
    });
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: DefaultColorSheet.grey300, width: 1),
            ),
          ),
          child: BottomAppBar(
            color: Colors.white,
            child: SizedBox(
              height: 60,
              child: FlipCard(
                key: flipKey,
                flipOnTouch: false,
                direction: FlipDirection.VERTICAL,
                front: Row(
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
                back: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionItem(
                      icon: Icons.delete,
                      label: "Delete",
                      color: DefaultColorSheet.red100,
                      onTap: onDelete,
                    ),
                    // _actionItem(
                    //   icon: LucideIcons.pin,
                    //   label: "Pin",
                    //   color: Colors.blue,
                    //   onTap: () {},
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _actionItem({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        PrimaryText(label, fontSize: 12, color: color),
      ],
    ),
  );
}
