import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/data/settins_main_data.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/screens/search/search_group_item.dart';
import 'package:my_app/widgets/screens/settings/settingsMain/setting_menu_item.dart';
import 'package:my_app/widgets/screens/settings/settingsMain/support_ticket_sheet.dart';
import 'package:my_app/widgets/screens/settings/settingsMain/theme_selection_sheet.dart';

class SettingsMain extends ConsumerWidget {
  const SettingsMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = ref.read(userPreferenceTableProvider.notifier).getUser();
    return PrimaryContainer(
      children: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            StreamBuilder<UserModel?>(
              stream: userStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final user = snapshot.data!;
                debugPrint(user.toString());
                return SearchGroupItem(
                  item: SearchItem(
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    bio: (user.bio?.trim().isNotEmpty ?? false)
                        ? user.bio ?? user.email
                        : user.email,
                    profilePicUrl: user.profilePic ?? '',
                    media: user.media,
                  ),

                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.profileEdit);
                  },
                  actionWidget: [
                    const Spacer(),
                    Icon(
                      Icons.qr_code_scanner,
                      color: DefaultColorSheet.green400,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
            Divider(color: DefaultColorSheet.divider(context)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final item = settingMenuData[index];
                  return SettingMenuItem(
                    item: item,
                    onTap: item.link == 'theme_settings'
                        ? () => ThemeSelectionSheet.show(context)
                        : item.link == 'support_sheet'
                            ? () => SupportTicketSheet.show(context)
                            : null,
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 30),
                itemCount: settingMenuData.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
