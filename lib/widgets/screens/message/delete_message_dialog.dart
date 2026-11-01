import 'package:flutter/material.dart';

enum DeleteMessageType {
  everyone,
  me,
}

Future<DeleteMessageType?> showDeleteMessageDialog(
  BuildContext context, {
  required bool canDeleteForEveryone,
}) {
  return showDialog<DeleteMessageType>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete message?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        content: Text(
          canDeleteForEveryone
              ? 'You can delete this message for everyone or only for yourself.'
              : 'This message will be removed from your chat.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          if (canDeleteForEveryone)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(DeleteMessageType.everyone),
              child: const Text(
                'Delete for everyone',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(DeleteMessageType.me),
            child: Text(
              'Delete for me',
              style: TextStyle(
                color: canDeleteForEveryone ? Colors.grey.shade800 : Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      );
    },
  );
}

