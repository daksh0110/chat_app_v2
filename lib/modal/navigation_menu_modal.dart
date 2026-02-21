import 'package:flutter/material.dart';

class NavigationMenuModal {
  final String label;
  final IconData icon;
  final Widget Function({Object? data}) screen;
  final PreferredSizeWidget Function(BuildContext) appBar;

  NavigationMenuModal({
    required this.label,
    required this.icon,
    required this.screen,
    required this.appBar,
  });
}
