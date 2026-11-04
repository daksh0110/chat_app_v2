import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/screens/settings/settings_main_modal.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class SettingMenuItem extends StatelessWidget {
  const SettingMenuItem({super.key, required this.item, this.onTap});
  final SettingsMainModal item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = DefaultColorSheet.isDark(context);

    return InkWell(
      onTap: onTap ??
          () {
            if (item.link.isNotEmpty) {
              Navigator.pushNamed(context, item.link);
            }
          },
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? DefaultColorSheet.darkSurface
                  : DefaultColorSheet.green100,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(
              item.icon,
              color: isDark
                  ? DefaultColorSheet.darkTextPrimary
                  : DefaultColorSheet.green400,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryText(
                item.name,
                textAlign: TextAlign.left,
                fontSize: 16,
                color: DefaultColorSheet.textPrimary(context),
              ),
              if (item.description?.isNotEmpty ?? false)
                PrimaryText(
                  item.description!,
                  textAlign: TextAlign.left,
                  color: DefaultColorSheet.textSecondary(context),
                  fontSize: 12,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
