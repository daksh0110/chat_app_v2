import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/screens/settings/settings_main_modal.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class SettingMenuItem extends StatelessWidget {
  const SettingMenuItem({super.key, required this.item});
  final SettingsMainModal item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: DefaultColorSheet.green100,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(10),
            child: Icon(item.icon),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryText(
                item.name,
                textAlign: TextAlign.left,
                fontSize: 16,
                color: Colors.black,
              ),
              if (item.description?.isNotEmpty ?? false)
                PrimaryText(
                  item.description!,
                  textAlign: TextAlign.left,
                  color: DefaultColorSheet.grey500,
                  fontSize: 12,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
