import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

const List<String> kDefaultReactionEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

enum MessageContextActionType {
  react,
  reply,
  copy,
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
}

/// A floating context menu with:
/// 1. Quick reaction emojis + a "+" button for all emojis
/// 2. Action items (Reply, Copy)
class MessageContextMenu extends StatelessWidget {
  final Set<String> myReactedEmojis;
  final bool canReply;
  final bool canCopy;
  final String messageText;
  final void Function(MessageContextMenuResult result) onSelect;
  final VoidCallback onOpenFullEmojiPicker;

  const MessageContextMenu({
    super.key,
    this.myReactedEmojis = const {},
    this.canReply = true,
    this.canCopy = true,
    this.messageText = '',
    required this.onSelect,
    required this.onOpenFullEmojiPicker,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top: Reaction Bar
        Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          shadowColor: Colors.black38,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...kDefaultReactionEmojis.map((emoji) {
                  final isSelected = myReactedEmojis.contains(emoji);
                  return GestureDetector(
                    onTap: () => onSelect(MessageContextMenuResult.react(emoji)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE8F5E9)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF00A884),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                }),
                // "+" Button to pick ANY other reaction
                GestureDetector(
                  onTap: onOpenFullEmojiPicker,
                  child: Container(
                    margin: const EdgeInsets.only(left: 4, right: 2),
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 22,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Bottom: Action Menu Card
        Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          shadowColor: Colors.black26,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
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
                    Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
                  if (canCopy)
                    _ActionTile(
                      icon: LucideIcons.copy,
                      iconColor: Colors.grey.shade700,
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
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
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
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
  Set<String> myReactedEmojis = const {},
  bool canReply = true,
  bool canCopy = true,
  String messageText = '',
}) async {
  final dialogResult = await showDialog<dynamic>(
    context: context,
    barrierColor: Colors.black26,
    builder: (ctx) {
      final screenWidth = MediaQuery.sizeOf(ctx).width;
      const menuWidth = 320.0;

      double left = tapPosition.dx - menuWidth / 2;
      if (left < 10) left = 10;
      if (left + menuWidth > screenWidth - 10) {
        left = screenWidth - menuWidth - 10;
      }

      double top = tapPosition.dy - 120;
      if (top < 50) top = tapPosition.dy + 10;

      return Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: MessageContextMenu(
              myReactedEmojis: myReactedEmojis,
              canReply: canReply,
              canCopy: canCopy,
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

/// Bottom sheet with categorized emojis for full selection.
Future<String?> showFullEmojiPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
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
    return DefaultTabController(
      length: _emojiCategories.length,
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      'React with any emoji',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
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
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search emoji...',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade400),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
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
                  labelColor: const Color(0xFF00A884),
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: const Color(0xFF00A884),
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: _emojiCategories.keys.map((cat) => Tab(text: cat)).toList(),
                ),

                const Divider(height: 1),

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
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    final allEmojis = _emojiCategories.values.expand((list) => list).toSet().toList();
    // Filter matching query or display all if no query
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
