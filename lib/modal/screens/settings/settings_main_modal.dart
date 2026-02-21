import 'package:flutter/material.dart';

class SettingsMainModal {
  final String name;
  final String? description;
  final IconData icon;

  SettingsMainModal({
    required this.name,
    this.description = "",
    required this.icon,
  });
}
