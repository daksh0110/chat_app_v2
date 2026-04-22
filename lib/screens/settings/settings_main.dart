import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/data/settins_main_data.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/screens/search/search_group_item.dart';
import 'package:my_app/widgets/screens/settings/settingsMain/setting_menu_item.dart';

class SettingsMain extends ConsumerWidget {
  const SettingsMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(settingsUserProvider);
    if (user == null) {
      return const SizedBox.shrink();
    }

    return PrimaryContainer(
      children: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            SearchGroupItem(
              item: SearchItem(
                id: user.id,
                name: user.name,
                profilePic: user.profilePictureUrl ?? "",
                subtitle: user.email,
                profilePicUrl: user.profilePictureUrl,
              ),
              actionWidget: [
                const Spacer(),
                Icon(Icons.qr_code_scanner, color: DefaultColorSheet.green400),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: DefaultColorSheet.grey600),
            const SizedBox(height: 30),

            // Expanded(
            //   child: ListView.separated(
            //     shrinkWrap: true,
            //     itemBuilder: (context, index) {
            //       return SettingMenuItem(item: settingMenuData[index]);
            //     },
            //     separatorBuilder: (context, index) => SizedBox(height: 30),
            //     itemCount: settingMenuData.length,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
