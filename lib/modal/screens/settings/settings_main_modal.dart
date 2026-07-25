import 'package:flutter/material.dart';
import 'package:my_app/core/app_routes.dart';

class SettingsMainModal {
  final String name;
  final String? description;
  final IconData icon;
  final String link;

  SettingsMainModal({
    required this.name,
    this.description = "",
    required this.icon,
    this.link = AppRoutes.home,
  });
}
