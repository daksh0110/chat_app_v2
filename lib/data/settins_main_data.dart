import 'package:flutter/material.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/modal/screens/settings/settings_main_modal.dart';

final List<SettingsMainModal> settingMenuData = [
  SettingsMainModal(
    name: "Account",
    description: "Privacy, security, change number, Sign out",
    icon: Icons.key_sharp,
    link: AppRoutes.accountsMain,
  ),
  SettingsMainModal(
    name: "Appearance",
    description: "Theme mode (Light, Dark, System default)",
    icon: Icons.dark_mode_outlined,
    link: "theme_settings",
  ),
  SettingsMainModal(
    name: "Archived Chats",
    description: "View and manage archived conversations",
    icon: Icons.archive_outlined,
    link: AppRoutes.archivedChats,
  ),
];
