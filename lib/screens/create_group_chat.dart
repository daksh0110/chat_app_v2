import 'dart:async';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/util/get_file_type.dart';
import 'package:my_app/data/services/chat_sync_service.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/screens/select_members_screen.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:toastification/toastification.dart';

class CreateGroupChat extends ConsumerStatefulWidget {
  const CreateGroupChat({super.key});

  @override
  ConsumerState<CreateGroupChat> createState() {
    return _createGroupChatState();
  }
}

class _createGroupChatState extends ConsumerState<CreateGroupChat> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Uint8List? _pickedPhotoBytes;
  XFile? _pickedImageFile;
  List<UsersTableData> _selectedMembers = [];
  bool _isCreating = false;
  Timer? _createGroupTimeout;

  void _removePhoto() {
    setState(() {
      _pickedPhotoBytes = null;
      _pickedImageFile = null;
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
        assetType: "chat",
        entityType: "avatar",
        contentType: mime,
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

  Future<void> _pickPhoto() async {
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
        ToastHelper.show(
          context: context,
          message: 'Error picking image: $e',
          type: ToastificationType.error,
        );
      }
    }
  }

  void _navigateAndSelectMembers() async {
    final List<UsersTableData>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SelectMembersScreen(initialSelected: _selectedMembers),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMembers = result;
      });
    }
  }

  void _removeMember(UsersTableData user) {
    setState(() {
      _selectedMembers.removeWhere((u) => u.id == user.id);
    });
  }

  Future<void> _onCreateGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      ToastHelper.show(
        context: context,
        message: 'Please enter a group name',
        type: ToastificationType.warning,
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ToastHelper.show(
        context: context,
        message: 'Please select at least one member',
        type: ToastificationType.warning,
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      UploadAttachment? media;
      if (_pickedImageFile != null) {
        media = await uploadImage(_pickedImageFile);
        if (media == null) {
          throw Exception("Failed to upload group image");
        }
      }

      final groupData = {
        "name": _groupNameController.text.trim(),
        "description": _descriptionController.text.trim(),
        "userIds": _selectedMembers.map((m) => m.id).toList(),
        if (media != null) "media": media.toJson(),
      };

      final socket = ref.read(socketProvider);
      _createGroupTimeout?.cancel();
      _createGroupTimeout = Timer(const Duration(seconds: 15), () {
        if (!mounted || !_isCreating) return;
        setState(() {
          _isCreating = false;
        });
        ToastHelper.show(
          context: context,
          message: 'Create group timed out. Please try again.',
          type: ToastificationType.error,
        );
      });

      socket.createGroup(groupData, (response) async {
        _createGroupTimeout?.cancel();
        if (!mounted) return;
        setState(() {
          _isCreating = false;
        });

        if (response.success == true) {
          if (media != null && response.data?.chatId != null) {
            final database = ref.read(databaseProvider);
            final chatId = response.data!.chatId;
            final existing = await database.managers.mediaTable
                .filter((f) => f.actorId(chatId))
                .getSingleOrNull();

            if (existing == null) {
              await database.into(database.mediaTable).insert(
                    MediaTableCompanion.insert(
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      actorId: Value(chatId),
                      Type: Value(media.type),
                      contentType: Value(media.contentType),
                      location: Value(_pickedImageFile!.path),
                      name: Value(media.name),
                      key: Value(media.key),
                    ),
                  );
            } else {
              await (database.update(database.mediaTable)
                    ..where((tbl) => tbl.id.equals(existing.id)))
                  .write(
                MediaTableCompanion(
                  Type: Value(media.type),
                  contentType: Value(media.contentType),
                  location: Value(_pickedImageFile!.path),
                  name: Value(media.name),
                  key: Value(media.key),
                ),
              );
            }
          }

          final currentUser = ref.read(settingsUserProvider);
          if (currentUser != null) {
            await ChatSyncService(
              db: ref.read(databaseProvider),
              apiClient: ApiClient(),
            ).syncCreatedGroupEventPayload(
              rawPayload: response,
              currentUserId: currentUser.id,
            );
          }

          Navigator.pop(context);
          return;
        }

        ToastHelper.show(
          context: context,
          message: response.message,
          type: ToastificationType.error,
        );
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
        ToastHelper.show(
          context: context,
          message: 'Error: $e',
          type: ToastificationType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _createGroupTimeout?.cancel();
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: DefaultColorSheet.lightBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const PrimaryText(
          "Create Group",
          color: DefaultColorSheet.lightBlack,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Centered Group Image & Name Section
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                GestureDetector(
                                  onTap: _isCreating ? null : _pickPhoto,
                                  child: _pickedPhotoBytes != null
                                      ? CircleAvatar(
                                          radius: 50,
                                          backgroundImage: MemoryImage(
                                            _pickedPhotoBytes!,
                                          ),
                                        )
                                      : Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: DefaultColorSheet.green100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_outlined,
                                            color: DefaultColorSheet.primary,
                                            size: 40,
                                          ),
                                        ),
                                ),
                                if (!_isCreating) ...[
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
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: DefaultColorSheet.grey500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 0,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: _isCreating ? null : _pickPhoto,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: DefaultColorSheet.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _pickedPhotoBytes != null ? Icons.edit : Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _groupNameController,
                              textAlign: TextAlign.center,
                              enabled: !_isCreating,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: DefaultColorSheet.lightBlack,
                              ),
                              decoration: const InputDecoration(
                                hintText: "Group Name",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Group Description Section
                      const PrimaryText(
                        "Group Description",
                        color: DefaultColorSheet.grey500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        enabled: !_isCreating,
                        style: const TextStyle(
                          fontSize: 16,
                          color: DefaultColorSheet.lightBlack,
                        ),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "What's this group about?",
                          filled: true,
                          fillColor: DefaultColorSheet.grey600,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Invited Members Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const PrimaryText(
                            "Invited Members",
                            color: DefaultColorSheet.grey500,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          PrimaryText(
                            "${_selectedMembers.length} members",
                            fontSize: 14,
                            color: DefaultColorSheet.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Members Grid
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          // Add member button
                          GestureDetector(
                            onTap: _isCreating
                                ? null
                                : _navigateAndSelectMembers,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: DefaultColorSheet.grey200,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: DefaultColorSheet.grey400,
                              ),
                            ),
                          ),
                          ..._selectedMembers.map((user) {
                            return Stack(
                              children: [
                                UserBubble(
                                  profilePicUrl: user.profilePictureUrl,
                                  name: user.name,
                                  size: 60,
                                ),
                                if (!_isCreating)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _removeMember(user),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: DefaultColorSheet.red100,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Create Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: PrimaryButton(
                  text: "Create",
                  loading: _isCreating,
                  onPressed: _isCreating ? () {} : _onCreateGroup,
                  backgroundColor: DefaultColorSheet.green500,
                  borderColor: DefaultColorSheet.green500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
