import 'package:flutter/material.dart';
import 'package:my_app/modal/message_reaction_modal.dart';

/// Renders a row of emoji pills below a message bubble.
/// Each pill shows emoji + count. Highlighted if the current user reacted.
/// Tap toggles the reaction; long-press opens the details sheet.
class ReactionPills extends StatelessWidget {
  final List<ReactionGroup> reactions;
  final void Function(String emoji) onTap;
  final void Function(List<ReactionGroup> reactions) onLongPress;
  final bool isSender;

  const ReactionPills({
    super.key,
    required this.reactions,
    required this.onTap,
    required this.onLongPress,
    this.isSender = false,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        left: isSender ? 60 : 8,
        right: isSender ? 8 : 60,
      ),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Wrap(
          spacing: 4,
          runSpacing: 2,
          children: reactions.map((group) {
            return GestureDetector(
              onTap: () => onTap(group.emoji),
              onLongPress: () => onLongPress(reactions),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: group.hasReactedByMe
                      ? const Color(0xFFE8F5E9)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: group.hasReactedByMe
                        ? const Color(0xFF00A884)
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      group.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (group.count > 1) ...[
                      const SizedBox(width: 3),
                      Text(
                        '${group.count}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: group.hasReactedByMe
                              ? const Color(0xFF00A884)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

