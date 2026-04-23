import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/providers/user_profile_info_procider.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';
import 'package:my_app/widgets/screens/userProfile/profile_action_button.dart';
import 'package:my_app/widgets/screens/userProfile/profile_detail_item.dart';

class UserProfile extends ConsumerStatefulWidget {
  @override
  ConsumerState<UserProfile> createState() {
    return UserProfileState();
  }
}

class UserProfileState extends ConsumerState<UserProfile> {
  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String;
    final userAsync = ref.watch(userProfileProvider(userId));

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (info) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            toolbarHeight: 60,
            actionsPadding: const EdgeInsets.only(right: 16),
            backgroundColor: Colors.black,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ProfileActionButton(
                  icon: LucideIcons.ellipsis,
                  onTap: () {},
                  size: 35,
                  iconSize: 20,
                ),
              ),
            ],
          ),
          body: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 10),
                UserBubble(
                  profilePic: info.profilePicUrl ?? "",
                  name: info.name,
                  size: 80,
                  needActiveIndicator: false,
                ),
                const SizedBox(height: 10),
                PrimaryText(
                  info.name,
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    ProfileActionButton(icon: LucideIcons.messageCircleMore),
                    SizedBox(width: 20),
                    ProfileActionButton(icon: LucideIcons.phone),
                    SizedBox(width: 20),
                    ProfileActionButton(icon: LucideIcons.video),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PrimaryContainer(
                    children: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileDetailItem(title: "Name", value: info.name),
                            ProfileDetailItem(
                              title: "Email",
                              value: info.email ?? "",
                            ),
                            ProfileDetailItem(
                              title: "Bio",
                              value: info.bio!.isNotEmpty
                                  ? info.bio ?? ""
                                  : "--",
                            ),
                            Row(
                              children: [
                                PrimaryText(
                                  "Media Shared",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: DefaultColorSheet.grey500,
                                ),
                                const Spacer(),
                                InkWell(
                                  child: PrimaryText(
                                    "View all",
                                    color: DefaultColorSheet.green500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const PrimaryText(
                              "No media found",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
