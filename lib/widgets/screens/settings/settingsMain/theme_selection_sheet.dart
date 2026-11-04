import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ThemeSelectionSheet extends ConsumerWidget {
  const ThemeSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: DefaultColorSheet.containerBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => const ThemeSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<String>(
      stream: ref.read(userPreferenceTableProvider.notifier).watchThemeMode(),
      builder: (context, snapshot) {
        final currentMode = snapshot.data ?? 'system';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PrimaryText(
                'Choose Theme',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DefaultColorSheet.textPrimary(context),
              ),
              const SizedBox(height: 14),
              _ThemeOptionTile(
                title: 'System default',
                subtitle: 'Match system dark/light settings',
                icon: Icons.brightness_auto,
                value: 'system',
                selectedValue: currentMode,
                onSelected: (val) async {
                  await ref
                      .read(userPreferenceTableProvider.notifier)
                      .updateThemeMode(val);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              _ThemeOptionTile(
                title: 'Light mode',
                subtitle: 'Always use light theme',
                icon: Icons.light_mode,
                value: 'light',
                selectedValue: currentMode,
                onSelected: (val) async {
                  await ref
                      .read(userPreferenceTableProvider.notifier)
                      .updateThemeMode(val);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              _ThemeOptionTile(
                title: 'Dark mode',
                subtitle: 'Always use dark theme',
                icon: Icons.dark_mode,
                value: 'dark',
                selectedValue: currentMode,
                onSelected: (val) async {
                  await ref
                      .read(userPreferenceTableProvider.notifier)
                      .updateThemeMode(val);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const _ThemeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;
    final isDark = DefaultColorSheet.isDark(context);

    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? DefaultColorSheet.primary.withValues(alpha: 0.15)
                    : (isDark
                        ? DefaultColorSheet.darkSurface
                        : DefaultColorSheet.grey600),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? DefaultColorSheet.primary
                    : DefaultColorSheet.textSecondary(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryText(
                    title,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: DefaultColorSheet.textPrimary(context),
                  ),
                  const SizedBox(height: 2),
                  PrimaryText(
                    subtitle,
                    fontSize: 12,
                    color: DefaultColorSheet.textSecondary(context),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: DefaultColorSheet.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

