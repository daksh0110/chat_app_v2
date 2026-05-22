import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mime/mime.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
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

  void handleAttachment(String key) async {
    switch (key) {
      case "gallery":
        final images = await _picker.pickMultiImage(requestFullMetadata: true);
        setState(() {
          attachments.addAll(images);
        });
        return;
      case "video":
        final video = await _picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          setState(() {
            attachments.add(video);
          });
        }
        return;
      case "file":
        final result = await FilePicker.pickFiles(
          allowMultiple: true,
          type: FileType.any,
        );
        if (result != null && result.files.isNotEmpty) {
          final xFiles = result.files
              .where((f) => f.path != null)
              .map((f) => XFile(f.path!))
              .toList();
          setState(() {
            attachments.addAll(xFiles);
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
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: DefaultColorSheet.white100, width: 1),
        ),
      ),

      child: Column(
        children: [
          if (attachments.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.only(top: 8),
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: attachments.length,
                itemBuilder: (context, index) {
                  final attachment = attachments[index];
                  final isImage = _isImageFile(attachment);
                  final isVideo = _isVideoFile(attachment);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isImage ? null : Colors.grey[300],
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
                                  size: 22,
                                  color: Colors.grey[700],
                                ),
                              )
                            : null,
                      ),

                      Positioned(
                        top: -6,
                        right: 4,
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
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
          ],
          Center(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    showPopover(
                      context: context,
                      direction: PopoverDirection.top,
                      width: 220,
                      bodyBuilder: (context) => AttachmentPopover(
                        onTap: (key) => handleAttachment(key),
                      ),
                      arrowDxOffset: -160,
                    );
                  },
                  icon: const Icon(
                    LucideIcons.paperclip,
                    size: 24,
                    color: DefaultColorSheet.lightBlack,
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: DefaultColorSheet.disbaledButton,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: TextField(
                      controller: chatMessageController,
                      onChanged: onTyping,
                      minLines: 1,
                      maxLines: 4,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.copy),
                        ),
                        border: InputBorder.none,
                        hintText: "Write a message",
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: DefaultColorSheet.grey500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: (_isTyping || attachments.isNotEmpty)
                        ? InkWell(
                            key: const ValueKey('send'),
                            onTap: () {
                              final text = chatMessageController.text.trim();
                              if (text.isEmpty && attachments.isEmpty) return;
                              widget.onSend(text, List.from(attachments));
                              widget.onStopTyping();
                              setState(() {
                                _isTyping = false;
                                attachments.clear();
                              });
                              chatMessageController.clear();
                            },

                            child: Container(
                              padding: const EdgeInsets.all(11),
                              decoration: const BoxDecoration(
                                color: DefaultColorSheet.green500,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.sendHorizontal,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            key: const ValueKey('media'),
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Icon(
                                LucideIcons.camera,
                                size: 24,
                                color: DefaultColorSheet.lightBlack,
                              ),
                              SizedBox(width: 8),
                              Icon(
                                LucideIcons.mic,
                                size: 24,
                                color: DefaultColorSheet.lightBlack,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
