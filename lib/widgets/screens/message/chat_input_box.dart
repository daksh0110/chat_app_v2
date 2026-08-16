import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mime/mime.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/util/media_file_helper.dart';
import 'package:my_app/widgets/screens/message/attachment_modal.dart';
import 'package:popover/popover.dart';

class ChatInputBox extends StatefulWidget {
  final Function(String, List<XFile>) onSend;
  final Function() onTyping;
  final Function() onStopTyping;

  const ChatInputBox({
    super.key,
    required this.onSend,
    required this.onTyping,
    required this.onStopTyping,
  });

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  final chatMessageController = TextEditingController();
  final List<XFile> attachments = [];
  final ImagePicker _picker = ImagePicker();

  bool _isTyping = false;

  void onTyping(String text) {
    setState(() {
      _isTyping = text.isNotEmpty;
    });

    if (text.isEmpty) {
      widget.onStopTyping();
      return;
    }

    widget.onTyping();
  }

  bool _isImageFile(XFile file) {
    final mime = lookupMimeType(file.path) ?? '';
    return mime.startsWith('image/');
  }

  bool _isVideoFile(XFile file) {
    final mime = lookupMimeType(file.path) ?? '';
    return mime.startsWith('video/');
  }

  Future<void> handleAttachment(String key) async {
    switch (key) {
      case "gallery":
        final images = await _picker.pickMultiImage(requestFullMetadata: true);
        if (images.isEmpty) return;

        // Copy each picked image from the volatile cache to permanent storage.
        final permanentImages = await Future.wait(
          images.map((img) async {
            final permanentPath =
                await MediaFileHelper.copyPickedFileToAppDir(img);
            return XFile(permanentPath);
          }),
        );

        setState(() {
          attachments.addAll(permanentImages);
        });
        return;

      case "video":
        final video = await _picker.pickVideo(source: ImageSource.gallery);
        if (video == null) return;

        // Copy video from cache to permanent storage.
        final permanentVideoPath =
            await MediaFileHelper.copyPickedFileToAppDir(video);

        setState(() {
          attachments.add(XFile(permanentVideoPath));
        });
        return;

      case "file":
        final result = await FilePicker.pickFiles(
          allowMultiple: true,
          type: FileType.any,
        );

        if (result != null && result.files.isNotEmpty) {
          final pickedXFiles = result.files
              .where((f) => f.path != null)
              .map((f) => XFile(f.path!))
              .toList();

          // Copy each file from its picker path to permanent storage.
          final permanentFiles = await Future.wait(
            pickedXFiles.map((f) async {
              final permanentPath =
                  await MediaFileHelper.copyPickedFileToAppDir(f);
              return XFile(permanentPath);
            }),
          );

          setState(() {
            attachments.addAll(permanentFiles);
          });
        }
        return;

      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: DefaultColorSheet.white100, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Attachment previews
          if (attachments.isNotEmpty) ...[
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                itemCount: attachments.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 8);
                },
                itemBuilder: (context, index) {
                  final attachment = attachments[index];

                  final isImage = _isImageFile(attachment);
                  final isVideo = _isVideoFile(attachment);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isImage
                              ? Colors.transparent
                              : Colors.grey[100],
                          border: Border.all(
                            color: Colors.black.withOpacity(0.06),
                            width: 1,
                          ),
                          image: isImage
                              ? DecorationImage(
                                  image: FileImage(File(attachment.path)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !isImage
                            ? Center(
                                child: Icon(
                                  isVideo
                                      ? LucideIcons.video
                                      : LucideIcons.file,
                                  size: 21,
                                  color: Colors.grey[700],
                                ),
                              )
                            : null,
                      ),

                      // Remove attachment
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              attachments.removeAt(index);
                            });
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Message input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              SizedBox(
                width: 42,
                height: 48,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 21,
                  onPressed: () {
                    showPopover(
                      context: context,
                      direction: PopoverDirection.top,
                      width: 220,
                      bodyBuilder: (context) => AttachmentPopover(
                        onTap: (key) => handleAttachment(key),
                      ),
                      arrowDxOffset: -80,
                    );
                  },
                  icon: const Icon(
                    LucideIcons.paperclip,
                    size: 22,
                    color: DefaultColorSheet.lightBlack,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Text field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    maxHeight: 110,
                  ),
                  decoration: BoxDecoration(
                    color: DefaultColorSheet.disbaledButton,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: chatMessageController,
                    onChanged: onTyping,
                    minLines: 1,
                    maxLines: 4,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: DefaultColorSheet.lightBlack,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: "Write a message",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: DefaultColorSheet.grey500,
                        fontWeight: FontWeight.w500,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Existing send button
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: SizedBox(
                  key: const ValueKey('send'),
                  width: 48,
                  height: 48,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      final text = chatMessageController.text.trim();

                      if (text.isEmpty && attachments.isEmpty) {
                        return;
                      }

                      widget.onSend(text, List.from(attachments));

                      widget.onStopTyping();

                      setState(() {
                        _isTyping = false;
                        attachments.clear();
                      });

                      chatMessageController.clear();
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: DefaultColorSheet.green500,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.sendHorizontal,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
