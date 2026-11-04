import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';

final themeModeProvider = StreamProvider<ThemeMode>((ref) {
  final notifier = ref.watch(userPreferenceTableProvider.notifier);
  return notifier.watchThemeMode().map((mode) {
    switch (mode.toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  });
});

