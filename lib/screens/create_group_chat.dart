import 'dart:async';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/modal/group_creation_modal.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/create_group_chat_provider.dart';
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
  List<UserModel> _selectedMembers = [];
  bool _isCreating = false;
  Timer? _createGroupTimeout;
  final _formKey = GlobalKey<FormState>();

  void _removePhoto() {
    setState(() {
      _pickedPhotoBytes = null;
      _pickedImageFile = null;
    });
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
    final List<UserModel>? result = await Navigator.push(
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

  void _removeMember(UserModel user) {
    setState(() {
      _selectedMembers.removeWhere((u) => u.id == user.id);
    });
  }

  Future<void> _onCreateGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      UploadAttachment? media;

      final pickedImage = _pickedImageFile;

      if (pickedImage != null) {
        media = await ref
            .read(createGroupChatProvider.notifier)
            .uploadImage(pickedImage);

        if (!mounted) return;

        if (media == null) {
          throw Exception("Failed to upload media");
        }
      }

      final group = GroupCreationModal(
        name: _groupNameController.text.trim(),
        bio: _descriptionController.text.trim(),
        userIds: _selectedMembers.map((e) => e.id).toList(),
        media: media,
      );

      await ref.read(createGroupChatProvider.notifier).createGroup(group);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ToastHelper.show(
        context: context,
        message: e.toString(),
        type: ToastificationType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
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
        child: Form(
          key: _formKey,
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
                                            _pickedPhotoBytes != null
                                                ? Icons.edit
                                                : Icons.add,
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
                              TextFormField(
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter name';
                                  }
                                  return null;
                                },
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
                        TextFormField(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter description';
                            }
                            return null;
                          },
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
                                  UserBubble(name: user.name, size: 60),
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
      ),
    );
  }
}
