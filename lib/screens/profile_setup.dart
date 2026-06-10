import 'dart:typed_data';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/util/get_file_type.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/media_download_provider.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:toastification/toastification.dart';
import 'package:mime/mime.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final TextEditingController bioController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Uint8List? _pickedPhotoBytes;
  XFile? _pickedImageFile;
  String? _profilePicUrl;
  bool _isPickingPhoto = false;
  bool _isUploading = false;
  SearchItem? argsData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as SearchItem?;

    if (args != null) {
      argsData = args;
      if (args.bio != null && args.bio!.isNotEmpty) {
        bioController.text = args.bio!;
      }
      if (args.profilePicUrl != null && args.profilePicUrl!.isNotEmpty) {
        setState(() {
          _profilePicUrl = args.profilePicUrl;
        });
      }
    }
  }

  Future<void> _pickPhoto() async {
    setState(() {
      _isPickingPhoto = true;
    });

    try {
      final XFile? pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        final bytes = await pickedImage.readAsBytes();
        setState(() {
          _pickedPhotoBytes = bytes;
          _pickedImageFile = pickedImage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }

    setState(() {
      _isPickingPhoto = false;
    });
  }

  void _removePhoto() {
    setState(() {
      _pickedPhotoBytes = null;
    });
  }

  Future<UploadAttachment?> uploadImage(XFile? pickedImageFile) async {
    if (pickedImageFile == null) {
      return null;
    }

    try {
      final mime =
          lookupMimeType(pickedImageFile.path) ?? "application/octet-stream";

      final presignedUrl = await UploadService(ApiClient()).getPresignedUrl(
        assetType: "user",
        entityType: "avatar",
        contentType: mime,
        entityId: argsData?.id,
      );

      if (!presignedUrl.success || presignedUrl.data == null) {
        ToastHelper.show(
          context: context,
          message: "Failed to upload media",
          type: ToastificationType.error,
        );
        return null;
      }

      final response = presignedUrl.data!;

      final result = await UploadService(ApiClient()).uploadToSignedUrl(
        await pickedImageFile.readAsBytes(),
        response.url,
        mime,
      );

      if (result == 200) {
        return UploadAttachment(
          contentType: mime,
          key: response.key ?? "",
          type: getMediaType(mime),
          name: pickedImageFile.name,
        );
      }

      ToastHelper.show(
        context: context,
        message: "Upload failed",
        type: ToastificationType.error,
      );

      return null;
    } catch (e) {
      ToastHelper.show(
        context: context,
        message: "Something went wrong",
        type: ToastificationType.error,
      );

      return null;
    }
  }

  void _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'accessToken');
      final apiClient = ApiClient();

      UploadAttachment? media;
      String? localPath;

      if (_pickedImageFile == null && _profilePicUrl == null) {
        final result = await UserApiService(apiClient).updateProfile(
          token: token ?? "",
          bio: bioController.text.trim().isNotEmpty
              ? bioController.text.trim()
              : null,
          media: null,
        );

        if (result.success) {
          if (!mounted) return;

          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else {
          ToastHelper.show(
            context: context,
            message: result.message,
            type: ToastificationType.error,
          );
        }

        return;
      }

      if (_pickedImageFile != null) {
        media = await uploadImage(_pickedImageFile);

        if (media == null) {
          throw Exception("Failed to upload image");
        }

        localPath = _pickedImageFile!.path;
      } else {
        final localFile = await ref
            .read(mediaDownloadProvider.notifier)
            .saveImageUrlLocally(_profilePicUrl!);

        localPath = localFile.path;

        media = await uploadImage(localFile);

        if (media == null) {
          throw Exception("Failed to upload Google profile image");
        }
      }

      final database = ref.read(databaseProvider);

      final existing = await database.managers.mediaTable
          .filter((f) => f.actorId(argsData?.id))
          .getSingleOrNull();

      if (existing == null) {
        await database
            .into(database.mediaTable)
            .insert(
              MediaTableCompanion.insert(
                createdAt: DateTime.now().millisecondsSinceEpoch,
                actorId: Value(argsData?.id),
                Type: Value(media.type),
                contentType: Value(media.contentType),
                location: Value(localPath),
                name: Value(media.name),
                key: Value(media.key),
              ),
            );
      } else {
        await (database.update(
          database.mediaTable,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          MediaTableCompanion(
            Type: Value(media.type),
            contentType: Value(media.contentType),
            location: Value(localPath),
            name: Value(media.name),
            key: Value(media.key),
          ),
        );
      }

      final result = await UserApiService(apiClient).updateProfile(
        token: token ?? "",
        bio: bioController.text.trim().isNotEmpty
            ? bioController.text.trim()
            : null,
        media: media,
      );

      if (result.success) {
        if (!mounted) return;

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      } else {
        ToastHelper.show(
          context: context,
          message: result.message,
          type: ToastificationType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(
          context: context,
          message: 'Failed to update profile: $e',
          type: ToastificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = _pickedPhotoBytes != null
        ? CircleAvatar(
            radius: 54,
            backgroundColor: DefaultColorSheet.primary.withOpacity(0.12),
            backgroundImage: MemoryImage(_pickedPhotoBytes!),
          )
        : _profilePicUrl != null
        ? CircleAvatar(
            radius: 54,
            backgroundColor: DefaultColorSheet.primary.withOpacity(0.12),
            backgroundImage: NetworkImage(_profilePicUrl!),
          )
        : CircleAvatar(
            radius: 54,
            backgroundColor: DefaultColorSheet.primary.withOpacity(0.08),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 34,
              color: DefaultColorSheet.primary,
            ),
          );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const PrimaryText(
          'Profile Setup',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const PrimaryText(
                  'Add a photo and a short bio so friends can recognize you.',
                  fontSize: 14,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    imageWidget,
                    if (_pickedPhotoBytes != null)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: GestureDetector(
                          onTap: _removePhoto,
                          child: Container(
                            decoration: BoxDecoration(
                              color: DefaultColorSheet.grey200,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: DefaultColorSheet.grey500,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 2,
                      bottom: 5,
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: Container(
                          decoration: BoxDecoration(
                            color: DefaultColorSheet.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            _pickedPhotoBytes != null ? Icons.edit : Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const PrimaryText(
                  'Profile photo (optional)',
                  fontSize: 12,
                  color: DefaultColorSheet.grey500,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: bioController,
                  maxLines: 4,
                  maxLength: 100,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Small Bio',
                    hintText: 'Tell people a little bit about yourself',
                    filled: true,
                    fillColor: DefaultColorSheet.primary.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: DefaultColorSheet.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: DefaultColorSheet.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.length > 100) {
                      return 'Bio can be at most 100 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_pickedPhotoBytes != null) const SizedBox(height: 10),
                PrimaryButton(
                  text: _isUploading ? 'Uploading...' : 'Continue',
                  onPressed: _isUploading ? () {} : _onContinue,
                  backgroundColor: _isUploading
                      ? DefaultColorSheet.disbaledButton
                      : DefaultColorSheet.primary,
                  borderColor: _isUploading
                      ? DefaultColorSheet.disbaledButton
                      : DefaultColorSheet.primary,
                  textColor: _isUploading
                      ? DefaultColorSheet.grey500
                      : Colors.white,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                  },
                  child: const PrimaryText(
                    'Skip for now',
                    fontSize: 14,
                    color: DefaultColorSheet.grey500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
