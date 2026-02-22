import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/modal/navigation_menu_modal.dart';
import 'package:my_app/screens/homescreen.dart';
import 'package:my_app/screens/settings/settings_main.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

final List<NavigationMenuModal> menu = [
  NavigationMenuModal(
    label: "Message",
    icon: LucideIcons.messageCircleMore,
    screen: ({dynamic data}) => Homescreen(data: data),
    appBar: (context) => AppBar(
      toolbarHeight: 90,
      actionsPadding: const EdgeInsets.all(24),
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
  ),
  NavigationMenuModal(
    label: "Calls",
    icon: LucideIcons.phone,
    screen: ({data}) => const Center(),
    appBar: (context) => AppBar(
      toolbarHeight: 90,
      actionsPadding: const EdgeInsets.all(24),
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
      title: PrimaryText("Calls", fontSize: 20, color: Colors.white),
    ),
  ),
  NavigationMenuModal(
    label: "Contacts",
    icon: LucideIcons.circleUserRound,
    screen: ({data}) => const SettingsMain(),
    appBar: (context) => AppBar(
      toolbarHeight: 90,
      actionsPadding: const EdgeInsets.all(24),
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
      title: PrimaryText("Contacts", fontSize: 20, color: Colors.white),
    ),
  ),
  NavigationMenuModal(
    label: "Settings",
    icon: LucideIcons.settings,
    screen: ({data}) => const SettingsMain(),
    appBar: (context) => AppBar(
      toolbarHeight: 90,
      actionsPadding: const EdgeInsets.all(24),
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
      title: PrimaryText("Settings", fontSize: 20, color: Colors.white),
    ),
  ),
];
