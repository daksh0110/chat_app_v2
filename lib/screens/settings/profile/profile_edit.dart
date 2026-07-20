import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

import 'package:my_app/providers/image_picker_provider.dart';
import 'package:my_app/providers/profile_edit_provider.dart';

import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/primary_text_field.dart';
import 'package:my_app/widgets/comman/primary_textfield_area.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';
import 'package:popover/popover.dart';
import 'package:toastification/toastification.dart';

class ProfileEdit extends ConsumerStatefulWidget {
  const ProfileEdit({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _profileEditState();
  }
}

class _profileEditState extends ConsumerState<ProfileEdit> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController bioController;
  late final TextEditingController profilePhotoController;
  XFile? image;
  late final String userId;
  String _originalBio = '';
  String _originalProfilePhoto = '';

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    emailController = TextEditingController();
    bioController = TextEditingController();
    profilePhotoController = TextEditingController();
    bioController.addListener(_onChanged);
    profilePhotoController.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    profilePhotoController.dispose();
    super.dispose();
  }

  void _selectImage() async {
    final picker = ref.read(imagePickerProvider);
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      profilePhotoController.text = image!.path;
    });
  }

  void _removePhoto() {
    setState(() {
      profilePhotoController.text = "";
    });
  }

  bool get hasChanges {
    final bool bioChange = bioController.text != _originalBio;
    final bool profileChange =
        profilePhotoController.text != _originalProfilePhoto;
    return bioChange || profileChange;
  }

  Future<void> _onSubmit() async {
    if (!hasChanges) return;

    try {
      await ref
          .read(profileEditProvider.notifier)
          .updateProfile(
            userId: userId,
            name: nameController.text,
            email: emailController.text,
            bio: bioController.text,
            image: image,
            profileChanged:
                profilePhotoController.text != _originalProfilePhoto,
          );

      if (!mounted) return;

      ToastHelper.show(
        context: context,
        message: "Profile updated successfully",
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ToastHelper.show(
        context: context,
        message: e.toString(),
        type: ToastificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileEditProvider);
    final isLoading = profileState.isLoading;
    final userAsync = ref.watch(userProvider);

    userAsync.whenData((user) {
      if (user == null) return;
      if (nameController.text.isEmpty) {
        nameController.text = user.name;
        emailController.text = user.email;
        bioController.text = user.bio ?? '';
        profilePhotoController.text = user.profilePic ?? '';
        _originalBio = user.bio ?? '';
        _originalProfilePhoto = user.profilePic ?? '';
        userId = user.id;
      }
    });

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
                              _selectImage();
                              Navigator.pop(popoverContext);
                            },
                            onEditPhoto: () {
                              _selectImage();
                              Navigator.pop(popoverContext);
                            },
                            onRemovePhoto: () {
                              _removePhoto();
                              Navigator.pop(popoverContext);
                            },
                            profilePhoto: profilePhotoController,
                          ),
                        );
                      },
                      child: UserBubble(
                        name: nameController.text,
                        size: 128,
                        profilePicUrl: profilePhotoController.text,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                PrimaryTextField(
                  label: "Name",
                  disabled: true,
                  controller: nameController,
                ),
                const SizedBox(height: 40),
                PrimaryTextField(
                  label: "Email",
                  disabled: true,
                  controller: emailController,
                ),
                const SizedBox(height: 40),
                PrimaryTextAreaField(
                  labelText: "",
                  hintText: "Please Enter your bio",
                  controller: bioController,
                  disabled: isLoading,
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  text: isLoading ? "Updating profile" : "Update profile",
                  onPressed: (hasChanges || isLoading) ? _onSubmit : () {},
                  backgroundColor: (!hasChanges || isLoading)
                      ? DefaultColorSheet.disbaledButton
                      : DefaultColorSheet.primary,
                  borderColor: (!hasChanges || isLoading)
                      ? DefaultColorSheet.disbaledButton
                      : DefaultColorSheet.primary,
                  textColor: (!hasChanges || isLoading)
                      ? DefaultColorSheet.grey500
                      : Colors.white,
                ),
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
    required this.profilePhoto,
  });

  final VoidCallback onAddPhoto;
  final VoidCallback onEditPhoto;
  final VoidCallback onRemovePhoto;
  final TextEditingController profilePhoto;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (profilePhoto.text.isEmpty) ...[
            ListTile(
              leading: const Icon(LucideIcons.camera, size: 20),
              title: const Text('Add photo'),
              dense: true,
              onTap: onAddPhoto,
            ),
          ] else ...[
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
        ],
      ),
    );
  }
}
