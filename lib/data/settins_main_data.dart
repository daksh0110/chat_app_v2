import 'package:flutter/material.dart';
import 'package:my_app/modal/screens/settings/settings_main_modal.dart';

final List<SettingsMainModal> settingMenuData = [
  SettingsMainModal(
    name: "Account",
    description: "Privacy, security, change number",
    icon: Icons.key_sharp,
  ),
  SettingsMainModal(
    name: "Chat",
    description: "Chat history, theme, wallpapers",
    icon: Icons.chat_bubble_outline,
  ),
  SettingsMainModal(
    name: "Notifications",
    description: "Messages, group and others",
    icon: Icons.notifications_none,
  ),
  SettingsMainModal(
    name: "Help",
    description: "Help center, contact us, privacy policy",
    icon: Icons.help_outline,
  ),
  SettingsMainModal(
    name: "Storage and data",
    description: "Network usage, storage usage",
    icon: Icons.storage,
  ),
  SettingsMainModal(
    name: "Invite a friend",
    description: "",
    icon: Icons.person_add_alt_1,
  ),
];
