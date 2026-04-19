import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/userProfile/profile_action_button.dart';
import 'package:my_app/widgets/screens/userProfile/profile_detail_item.dart';

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() {
    return UserProfileState();
  }
}

class UserProfileState extends State<UserProfile> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = ModalRoute.of(context)!.settings.arguments as String;
  }

  @override
  Widget build(BuildContext context) {
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
            CircleAvatar(
              radius: 40,
              backgroundImage: const AssetImage("assets/no-image-icon.jpg"),
            ),
            const SizedBox(height: 10),
            PrimaryText(
              "user name",
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
                        ProfileDetailItem(title: "Name", value: "user name"),
                        ProfileDetailItem(
                          title: "Email",
                          value: "user@example.com",
                        ),
                        ProfileDetailItem(
                          title: "Bio",
                          value: "User bio goes here...",
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
  }
}
