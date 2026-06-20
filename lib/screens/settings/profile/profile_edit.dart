import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/providers/edit_profile_provider.dart';
import 'package:my_app/providers/image_picker_provider.dart';
import 'package:my_app/providers/notifiers/aws_notifier.dart';
import 'package:my_app/providers/secure_storage_provider.dart';
import 'package:my_app/services/database_services/media_table_service.dart';
import 'package:my_app/services/database_services/user_table_service.dart';
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
  bool isLoading = false;
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
    if (!hasChanges || isLoading) return;

    try {
      setState(() {
        isLoading = true;
      });

      final bool profileChange =
          profilePhotoController.text != _originalProfilePhoto;

      UploadAttachment? media;

      if (profileChange) {
        media = await ref
            .read(AwsNotifierProvider.notifier)
            .uploadImage(image, userId);

        if (media == null) {
          throw Exception('Failed to upload image');
        }
      }

      final token = await ref
          .read(flutterSecureStorageProvider)
          .read(key: "accessToken");

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      // API update
      final result = await UserApiService(ApiClient()).updateProfile(
        token: token,
        bio: bioController.text.trim().isNotEmpty
            ? bioController.text.trim()
            : null,
        media: media,
      );

      if (!mounted) return;

      if (!result.success) {
        ToastHelper.show(
          context: context,
          message: result.message,
          type: ToastificationType.error,
        );
        return;
      }

      if (media != null) {
        try {
          debugPrint("key: ${media.key}");
          await addOrUpdateMediaDocument(
            UploadAttachment(
              key: media.key,
              contentType: media.contentType,
              type: media.type,
              actorId: userId,
              location: image?.path,
              name: media.name,
            ),
            ref,
            userId,
          );
        } catch (e) {
          debugPrint('Media update failed: $e');
          ToastHelper.show(
            context: context,
            message: 'Profile updated, but failed to save image locally.',
            type: ToastificationType.error,
          );
          return;
        }
      }

      try {
        await updateUserProfile(
          ref,
          SearchItem(
            id: userId,
            name: nameController.text,
            bio: bioController.text,
            email: emailController.text,
            media: media,
          ),
        );
      } catch (e) {
        debugPrint('User update failed: $e');

        ToastHelper.show(
          context: context,
          message: 'Profile updated on server but failed locally.',
          type: ToastificationType.error,
        );
        return;
      }

      ToastHelper.show(context: context, message: result.message);

      Navigator.pop(context);
    } catch (e, stack) {
      debugPrint('Profile update error: $e');
      debugPrintStack(stackTrace: stack);

      if (mounted) {
        ToastHelper.show(
          context: context,
          message: e.toString(),
          type: ToastificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    userAsync.whenData((user) {
      if (user == null) return;
      if (nameController.text.isEmpty) {
        nameController.text = user.name;
        emailController.text = user.email ?? '';
        bioController.text = user.bio ?? '';
        profilePhotoController.text = user.profilePicUrl ?? "";
        _originalBio = user.bio ?? '';
        _originalProfilePhoto = user.profilePicUrl ?? '';
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
