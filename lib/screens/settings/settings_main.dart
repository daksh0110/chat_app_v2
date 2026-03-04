import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/data/settins_main_data.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/screens/search/search_group_item.dart';
import 'package:my_app/widgets/screens/settings/settingsMain/setting_menu_item.dart';

class SettingsMain extends StatelessWidget {
  const SettingsMain({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      children: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            SearchGroupItem(
              item: SearchItem(
                id: "1",
                name: "daksh",
                profilePic: "assets/screens/home/user2.png",
                subtitle: "Never give up 💪",
              ),
              actionWidget: [
                const Spacer(),
                Icon(Icons.qr_code_scanner, color: DefaultColorSheet.green400),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: DefaultColorSheet.grey600),
            const SizedBox(height: 30),

            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return SettingMenuItem(item: settingMenuData[index]);
                },
                separatorBuilder: (context, index) => SizedBox(height: 30),
                itemCount: settingMenuData.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
