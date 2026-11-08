import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/util/get_file_type.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/modal/group_profile_modal.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:toastification/toastification.dart';

class EditGroupSheet extends ConsumerStatefulWidget {
  final GroupProfile group;
  final String? fallbackProfilePic;

  const EditGroupSheet({
    super.key,
    required this.group,
    this.fallbackProfilePic,
  });

  static Future<void> show(
    BuildContext context, {
    required GroupProfile group,
    String? fallbackProfilePic,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditGroupSheet(
        group: group,
        fallbackProfilePic: fallbackProfilePic,
      ),
    );
  }

  @override
  ConsumerState<EditGroupSheet> createState() => _EditGroupSheetState();
}

class _EditGroupSheetState extends ConsumerState<EditGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  Uint8List? _pickedPhotoBytes;
  XFile? _pickedImageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _bioController = TextEditingController(text: widget.group.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedPhotoBytes = bytes;
        _pickedImageFile = picked;
      });
    } catch (e) {
      if (mounted) {
        ToastHelper.show(
          context: context,
          message: 'Error picking image: $e',
          type: ToastificationType.error,
        );
      }
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameController.text.trim();
    final newBio = _bioController.text.trim();

    setState(() => _isSaving = true);

    try {
      Map<String, dynamic>? mediaPayload;
      String? imageKey;

      if (_pickedImageFile != null) {
        final mime = lookupMimeType(_pickedImageFile!.path) ??
            'application/octet-stream';

        final presignedUrl = await UploadService(ApiClient()).getPresignedUrl(
          assetType: 'chat',
          entityType: 'avatar',
          contentType: mime,
        );

        if (!presignedUrl.success || presignedUrl.data == null) {
          throw Exception('Unable to generate presigned URL');
        }

        final response = presignedUrl.data!;
        final uploadStatus = await UploadService(ApiClient()).uploadToSignedUrl(
          await _pickedImageFile!.readAsBytes(),
          response.url,
          mime,
        );

        if (uploadStatus != 200) {
          throw Exception('Failed to upload image file');
        }

        imageKey = response.key ?? '';
        mediaPayload = {
          'key': imageKey,
          'name': _pickedImageFile!.name,
          'type': getMediaType(mime),
          'content_type': mime,
        };
      }

      // Emit single event to backend with all updated fields
      await ref.read(socketProvider).updateGroupProfile(
            chatId: widget.group.chatId,
            name: newName,
            bio: newBio,
            media: mediaPayload,
            image: imageKey,
          );

      if (mounted) {
        ToastHelper.show(
          context: context,
          message: 'Group profile updated successfully',
          type: ToastificationType.success,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Failed to update group: $e');
      if (mounted) {
        ToastHelper.show(
          context: context,
          message: e.toString().replaceFirst('Exception: ', ''),
          type: ToastificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildAvatar() {
    final effectiveUrl =
        widget.group.profilePicUrl ?? widget.fallbackProfilePic;

    ImageProvider? imageProvider;
    if (_pickedPhotoBytes != null) {
      imageProvider = MemoryImage(_pickedPhotoBytes!);
    } else if (effectiveUrl != null && effectiveUrl.isNotEmpty) {
      if (effectiveUrl.startsWith('http://') ||
          effectiveUrl.startsWith('https://')) {
        imageProvider = NetworkImage(effectiveUrl);
      } else if (File(effectiveUrl).existsSync()) {
        imageProvider = FileImage(File(effectiveUrl));
      }
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: DefaultColorSheet.primary.withValues(alpha: 0.15),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Text(
                    widget.group.name.isNotEmpty
                        ? widget.group.name[0].toUpperCase()
                        : 'G',
                    style: const TextStyle(
                      color: DefaultColorSheet.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isSaving ? null : _pickPhoto,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: DefaultColorSheet.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DefaultColorSheet.cardBg(context),
                    width: 2.5,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final cardBg = DefaultColorSheet.cardBg(context);
    final textPrimary = DefaultColorSheet.textPrimary(context);
    final isDark = DefaultColorSheet.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PrimaryText(
                      'Edit Group Info',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: DefaultColorSheet.appBarIcon(context),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAvatar(),
                const SizedBox(height: 22),
                PrimaryText(
                  'Group Name',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DefaultColorSheet.textSecondary(context),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  maxLines: 1,
                  maxLength: 50,
                  cursorColor: DefaultColorSheet.primary,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: DefaultColorSheet.inputFieldBg(context),
                    hintText: 'Group name',
                    hintStyle: TextStyle(
                      color: DefaultColorSheet.inputHintColor(context),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: DefaultColorSheet.divider(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: DefaultColorSheet.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Group name cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                PrimaryText(
                  'Group Description',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DefaultColorSheet.textSecondary(context),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  enabled: !_isSaving,
                  maxLines: 3,
                  maxLength: 250,
                  cursorColor: DefaultColorSheet.primary,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    counterStyle: TextStyle(
                      color: DefaultColorSheet.textSecondary(context),
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: DefaultColorSheet.inputFieldBg(context),
                    hintText: 'What is this group about?',
                    hintStyle: TextStyle(
                      color: DefaultColorSheet.inputHintColor(context),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: DefaultColorSheet.divider(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: DefaultColorSheet.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Save Changes',
                  loading: _isSaving,
                  onPressed: _isSaving ? () {} : _onSave,
                  backgroundColor: DefaultColorSheet.primary,
                  borderColor: DefaultColorSheet.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
