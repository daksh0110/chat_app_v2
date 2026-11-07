import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/screens/message/message_item_model.dart';

class PinnedMessageBanner extends StatefulWidget {
  final List<MessageItemModel> pinnedMessages;
  final void Function(MessageItemModel message)? onTap;
  final void Function(MessageItemModel message)? onUnpin;

  const PinnedMessageBanner({
    super.key,
    required this.pinnedMessages,
    this.onTap,
    this.onUnpin,
  });

  @override
  State<PinnedMessageBanner> createState() => _PinnedMessageBannerState();
}

class _PinnedMessageBannerState extends State<PinnedMessageBanner> {
  int _currentIndex = 0;

  @override
  void didUpdateWidget(covariant PinnedMessageBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentIndex >= widget.pinnedMessages.length) {
      _currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pinnedMessages.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeIndex = _currentIndex < widget.pinnedMessages.length
        ? _currentIndex
        : 0;
    final current = widget.pinnedMessages[safeIndex];
    final totalCount = widget.pinnedMessages.length;

    final previewText = current.message.isNotEmpty
        ? current.message
        : (current.attachments.isNotEmpty ? 'Attachment' : 'Message');

    return Material(
      color: DefaultColorSheet.surfaceBg(context),
      child: InkWell(
        onTap: () {
          widget.onTap?.call(current);
          if (totalCount > 1) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % totalCount;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: DefaultColorSheet.divider(context),
                width: 1,
              ),
              left: const BorderSide(
                color: DefaultColorSheet.green500,
                width: 3.5,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.pin,
                size: 16,
                color: DefaultColorSheet.green500,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          totalCount > 1
                              ? 'Pinned Message (${safeIndex + 1}/$totalCount)'
                              : 'Pinned Message',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: DefaultColorSheet.green500,
                          ),
                        ),
                        if (current.senderName.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '• ${current.senderName}',
                              style: TextStyle(
                                fontSize: 11,
                                color: DefaultColorSheet.textSecondary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      previewText,
                      style: TextStyle(
                        fontSize: 13,
                        color: DefaultColorSheet.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (widget.onUnpin != null)
                IconButton(
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(
                    LucideIcons.x,
                    size: 16,
                    color: DefaultColorSheet.grey500,
                  ),
                  onPressed: () => widget.onUnpin?.call(current),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

