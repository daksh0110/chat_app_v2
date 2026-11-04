import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

const List<String> kDefaultReactionEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

enum MessageContextActionType {
  react,
  reply,
  copy,
  delete,
}

class MessageContextMenuResult {
  final MessageContextActionType action;
  final String? emoji;

  const MessageContextMenuResult.react(this.emoji)
      : action = MessageContextActionType.react;
  const MessageContextMenuResult.reply()
      : action = MessageContextActionType.reply,
        emoji = null;
  const MessageContextMenuResult.copy()
      : action = MessageContextActionType.copy,
        emoji = null;
  const MessageContextMenuResult.delete()
      : action = MessageContextActionType.delete,
        emoji = null;
}

/// A floating context menu with:
/// 1. Quick reaction emojis + a "+" button for all emojis
/// 2. Action items (Reply, Copy)
class MessageContextMenu extends StatelessWidget {
  final Set<String> myReactedEmojis;
  final bool isSender;
  final bool canReply;
  final bool canCopy;
  final bool canDelete;
  final String messageText;
  final void Function(MessageContextMenuResult result) onSelect;
  final VoidCallback onOpenFullEmojiPicker;

  const MessageContextMenu({
    super.key,
    this.myReactedEmojis = const {},
    this.isSender = false,
    this.canReply = true,
    this.canCopy = true,
    this.canDelete = true,
    this.messageText = '',
    required this.onSelect,
    required this.onOpenFullEmojiPicker,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions = canReply || canCopy || canDelete;
    final isDark = DefaultColorSheet.isDark(context);
    final cardBg = DefaultColorSheet.cardBg(context);
    final dividerColor = DefaultColorSheet.divider(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Top: Reaction Bar
        Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(28),
          color: cardBg,
          shadowColor: Colors.black38,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...kDefaultReactionEmojis.map((emoji) {
                  final isSelected = myReactedEmojis.contains(emoji);
                  return GestureDetector(
                    onTap: () => onSelect(MessageContextMenuResult.react(emoji)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2.5,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DefaultColorSheet.primary.withValues(alpha: 0.18)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: DefaultColorSheet.primary,
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }),
                // "+" Button to pick ANY other reaction
                GestureDetector(
                  onTap: onOpenFullEmojiPicker,
                  child: Container(
                    margin: const EdgeInsets.only(left: 2, right: 1),
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? DefaultColorSheet.darkSurface
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 17,
                      color: DefaultColorSheet.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (hasActions) ...[
          const SizedBox(height: 8),

          // Bottom: Action Menu Card
          Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            color: cardBg,
            shadowColor: Colors.black26,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 160, maxWidth: 200),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canReply)
                      _ActionTile(
                        icon: LucideIcons.reply,
                        iconColor: DefaultColorSheet.green500,
                        title: 'Reply',
                        onTap: () => onSelect(const MessageContextMenuResult.reply()),
                      ),
                    if (canReply && canCopy)
                      Divider(height: 1, thickness: 0.5, color: dividerColor),
                    if (canCopy)
                      _ActionTile(
                        icon: LucideIcons.copy,
                        iconColor: DefaultColorSheet.textSecondary(context),
                        title: 'Copy',
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: messageText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message copied'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          onSelect(const MessageContextMenuResult.copy());
                        },
                      ),
                    if (canDelete) ...[
                      if (canReply || canCopy)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: dividerColor,
                        ),
                      _ActionTile(
                        icon: LucideIcons.trash2,
                        iconColor: Colors.redAccent,
                        title: 'Delete',
                        titleColor: Colors.redAccent,
                        onTap: () =>
                            onSelect(const MessageContextMenuResult.delete()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: titleColor ?? DefaultColorSheet.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenFullEmojiMarker {
  const _OpenFullEmojiMarker();
}

/// Shows the message context menu dialog positioned near tap position.
Future<MessageContextMenuResult?> showMessageContextMenu(
  BuildContext context, {
  required Offset tapPosition,
  bool isSender = false,
  Set<String> myReactedEmojis = const {},
  bool canReply = true,
  bool canCopy = true,
  bool canDelete = true,
  String messageText = '',
}) async {
  final dialogResult = await showDialog<dynamic>(
    context: context,
    barrierColor: Colors.black26,
    builder: (ctx) {
      final mediaQuery = MediaQuery.of(ctx);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;
      final safeTop = mediaQuery.padding.top + 16.0;
      final safeBottom = screenHeight - mediaQuery.padding.bottom - 16.0;

      // Reaction bar width with 6 emojis + plus icon + paddings is ~240.0
      // Context menu action card max width is 200.0
      const menuWidth = 245.0;
      final actionCount =
          (canReply ? 1 : 0) + (canCopy ? 1 : 0) + (canDelete ? 1 : 0);
      final double menuHeight =
          48.0 + (actionCount > 0 ? (8.0 + actionCount * 44.0) : 0.0);

      // Horizontal positioning:
      // If sender (right-aligned), anchor toward right side of tap
      // If receiver (left-aligned), anchor toward left side of tap
      double left = isSender
          ? (tapPosition.dx - menuWidth + 20.0)
          : (tapPosition.dx - 20.0);
      final maxLeft =
          (screenWidth - menuWidth - 12.0).clamp(12.0, screenWidth);
      left = left.clamp(12.0, maxLeft);

      // Vertical positioning:
      // Prefer placing the menu above the tap position so it doesn't collide with the input bar
      double top = tapPosition.dy - menuHeight - 12.0;
      if (top < safeTop) {
        // If not enough room above, place below
        top = tapPosition.dy + 12.0;
      }

      // Ensure menu never cuts off at the bottom or top of the screen
      if (top + menuHeight > safeBottom) {
        top = safeBottom - menuHeight;
      }
      if (top < safeTop) {
        top = safeTop;
      }

      return Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: MessageContextMenu(
              isSender: isSender,
              myReactedEmojis: myReactedEmojis,
              canReply: canReply,
              canCopy: canCopy,
              canDelete: canDelete,
              messageText: messageText,
              onSelect: (result) => Navigator.of(ctx).pop(result),
              onOpenFullEmojiPicker: () {
                Navigator.of(ctx).pop(const _OpenFullEmojiMarker());
              },
            ),
          ),
        ],
      );
    },
  );

  if (dialogResult is _OpenFullEmojiMarker) {
    if (context.mounted) {
      final pickedEmoji = await showFullEmojiPicker(context);
      if (pickedEmoji != null) {
        return MessageContextMenuResult.react(pickedEmoji);
      }
    }
    return null;
  }

  if (dialogResult is MessageContextMenuResult) {
    return dialogResult;
  }

  return null;
}

/// Opens bottom sheet with categorized emoji grid
Future<String?> showFullEmojiPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: DefaultColorSheet.cardBg(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _FullEmojiPickerSheet(),
  );
}

class _FullEmojiPickerSheet extends StatefulWidget {
  const _FullEmojiPickerSheet();

  @override
  State<_FullEmojiPickerSheet> createState() => _FullEmojiPickerSheetState();
}

class _FullEmojiPickerSheetState extends State<_FullEmojiPickerSheet> {
  static const Map<String, List<String>> _emojiCategories = {
    'Smileys': [
      '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃', '😉', '😊',
      '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙', '😋', '😛', '😜', '🤪',
      '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶', '😏',
      '😒', '🙄', '😬', '🤥', '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕',
      '🤢', '🤮', '🤧', '🥵', '🥶', '🥴', '😵', '🤯', '🤠', '🥳', '🥸', '😎',
      '🤓', '🧐', '😕', '😟', '🙁', '😮', '😯', '😲', '😳', '🥺', '😦', '😧',
      '😨', '😰', '😥', '😢', '😭', '😱', '😖', '😣', '😞', '😓', '😩', '😫',
      '🥱', '😤', '😡', '😠', '🤬', '😈', '👿', '💀', '💩', '🤡', '👻', '👽',
    ],
    'Gestures': [
      '👍', '👎', '👏', '🙌', '🫶', '👐', '🤲', '🤝', '🙏', '✍️', '💅', '🤳',
      '💪', '👈', '👉', '👆', '🖕', '👇', '☝️', '✌️', '🤞', '🫰', '🤟', '🤘',
      '🤙', '👋', '🤚', '🖐️', '✋', '🖖', '🫱', '🫲', '🫳', '🫴', '👌', '🤌',
      '🤏', '✊', '👊', '🤛', '🤜',
    ],
    'Hearts & Love': [
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔', '❣️', '💕',
      '💞', '💓', '💗', '💖', '💘', '💝', '💟', '🔥', '💯', '✨', '⭐', '🌟',
      '💫', '💥', '💢', '💤', '💨', '💦', '💬', '👁️', '🧠',
    ],
    'Fun & Party': [
      '🎉', '🎊', '🎈', '🎁', '🎂', '🍾', '🥂', '🍻', '🍺', '☕', '🍕', '🍔',
      '🍟', '🌭', '🍿', '🍩', '🍪', '🍦', '🏆', '🥇', '🥈', '🥉', '⚽', '🏀',
      '🏈', '🎾', '🎮', '🎲', '🎯', '🎨', '🎭', '🎬', '🎤', '🎧', '🎸',
    ],
    'Objects': [
      '💡', '📱', '💻', '📷', '📺', '⏰', '⏳', '🔑', '🔒', '🔓', '📦', '✉️',
      '📅', '📌', '📍', '🚀', '🚗', '🚲', '✈️', '⛵', '🏠', '🏢', '☀️', '🌙',
      '☁️', '🌈', '⚡', '❄️', '🌸', '🌺', '🌹', '🍀', '🐶', '🐱', '🐼', '🦁',
    ],
  };

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DefaultColorSheet.isDark(context);
    final cardBg = DefaultColorSheet.cardBg(context);
    final textPrimary = DefaultColorSheet.textPrimary(context);
    final textSecondary = DefaultColorSheet.textSecondary(context);
    final dividerColor = DefaultColorSheet.divider(context);

    return DefaultTabController(
      length: _emojiCategories.length,
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            color: cardBg,
            child: Column(
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'React with any emoji',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, size: 20, color: textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: textPrimary),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search emoji...',
                      hintStyle: TextStyle(fontSize: 14, color: textSecondary),
                      prefixIcon: Icon(Icons.search, size: 20, color: textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 16, color: textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? DefaultColorSheet.darkSurface
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // If searching, show flat filtered results
                if (_searchQuery.isNotEmpty)
                  Expanded(
                    child: _buildSearchResults(),
                  )
                else ...[
                  // Category tabs
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: DefaultColorSheet.primary,
                    unselectedLabelColor: textSecondary,
                    indicatorColor: DefaultColorSheet.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: _emojiCategories.keys.map((cat) => Tab(text: cat)).toList(),
                  ),

                  Divider(height: 1, color: dividerColor),

                  // Category views
                  Expanded(
                    child: TabBarView(
                      children: _emojiCategories.values.map((emojis) {
                        return GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemCount: emojis.length,
                          itemBuilder: (context, index) {
                            final emoji = emojis[index];
                            return InkWell(
                              onTap: () => Navigator.of(context).pop(emoji),
                              borderRadius: BorderRadius.circular(8),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    final allEmojis = _emojiCategories.values.expand((list) => list).toSet().toList();
    final results = allEmojis;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final emoji = results[index];
        return InkWell(
          onTap: () => Navigator.of(context).pop(emoji),
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        );
      },
    );
  }
}
