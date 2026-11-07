import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/modal/chat_settings_modal.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/providers/tables/chat_settings_table_provider.dart';

final chatSettingsSocketProvider =
    NotifierProvider<ChatSettingsSocketNotifier, void>(
  ChatSettingsSocketNotifier.new,
);

class ChatSettingsSocketNotifier extends Notifier<void> {
  bool _isListening = false;

  @override
  void build() {
    _isListening = false;
  }

  void listen() {
    if (_isListening) return;
    _isListening = true;
    final socketService = ref.read(socketProvider);

    // 1. Chat settings updated (from another device/session)
    socketService.listenChatSettingsUpdated((data) async {
      try {
        if (data is! Map) return;
        final rawSettings = data['settings'];
        if (rawSettings is Map) {
          final settings = ChatSettingsModal.fromJson(
            Map<String, dynamic>.from(rawSettings),
          );
          await ref
              .read(chatSettingsTableProvider.notifier)
              .upsertRemoteSettings(settings);
        }
      } catch (e) {
        debugPrint("Error handling chat_settings_updated socket event: $e");
      }
    });

    // 2. Disappearing messages updated by someone in this chat
    socketService.listenDisappearingMessagesUpdated((data) async {
      try {
        if (data is! Map) return;
        final chatId = (data['chat_id'] ?? data['chatId'])?.toString();
        final duration = data['duration'];
        if (chatId != null && duration != null) {
          await ref
              .read(chatSettingsTableProvider.notifier)
              .updateDisappearingDuration(
                chatId: chatId,
                durationSeconds: int.tryParse(duration.toString()) ?? 0,
              );
        }
      } catch (e) {
        debugPrint("Error handling disappearing_messages_updated: $e");
      }
    });
  }
}
