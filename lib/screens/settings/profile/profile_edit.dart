import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/primary_text_field.dart';
import 'package:my_app/widgets/comman/primary_textfield_area.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';
import 'package:popover/popover.dart';

class ProfileEdit extends ConsumerStatefulWidget {
  const ProfileEdit({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _profileEditState();
  }
}

class _profileEditState extends ConsumerState<ProfileEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: PrimaryText(
          "Edit Profile",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DefaultColorSheet.lightBlack,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(
                  builder: (avatarContext) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(64),
                      onTap: () {
                        showPopover(
                          context: avatarContext,
                          direction: PopoverDirection.bottom,
                          backgroundColor: Colors.white,
                          width: 220,
                          bodyBuilder: (popoverContext) => _ProfilePhotoPopover(
                            onAddPhoto: () {
                              Navigator.pop(popoverContext);
                            },
                            onEditPhoto: () {
                              Navigator.pop(popoverContext);
                            },
                            onRemovePhoto: () {
                              Navigator.pop(popoverContext);
                            },
                          ),
                        );
                      },
                      child: const UserBubble(name: "Test", size: 128),
                    );
                  },
                ),
                const SizedBox(height: 40),
                PrimaryTextField(label: "Name", disabled: true),
                const SizedBox(height: 40),
                PrimaryTextField(label: "Email", disabled: true),
                const SizedBox(height: 40),
                PrimaryTextAreaField(
                  labelText: "Bio",
                  hintText: "Please Enter your bio",
                ),
                const SizedBox(height: 40),
                PrimaryButton(text: "Update profile", onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePhotoPopover extends StatelessWidget {
  const _ProfilePhotoPopover({
    required this.onAddPhoto,
    required this.onEditPhoto,
    required this.onRemovePhoto,
  });

  final VoidCallback onAddPhoto;
  final VoidCallback onEditPhoto;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(LucideIcons.camera, size: 20),
            title: const Text('Add photo'),
            dense: true,
            onTap: onAddPhoto,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit, size: 20),
            title: const Text('Edit photo'),
            dense: true,
            onTap: onEditPhoto,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red, size: 20),
            title: const Text(
              'Remove photo',
              style: TextStyle(color: Colors.red),
            ),
            dense: true,
            onTap: onRemovePhoto,
          ),
        ],
      ),
    );
  }
}
