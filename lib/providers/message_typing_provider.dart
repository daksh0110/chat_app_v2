import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageTypingProvider =
    NotifierProvider<MessageTypingProvider, Map<String, bool>>(
      MessageTypingProvider.new,
    );

class MessageTypingProvider extends Notifier<Map<String, bool>> {
  final Map<String, Timer> _timers = {};

  @override
  Map<String, bool> build() {
    return {};
  }

  void receiveUserTyping(String userId) {
    state = {...state, userId: true};

    _timers[userId]?.cancel();

    _timers[userId] = Timer(const Duration(seconds: 1), () {
      final updated = {...state};
      updated.remove(userId);

      state = updated;
      _timers.remove(userId);
    });
  }

  void clearTyping(String userId) {
    _timers[userId]?.cancel();
    _timers.remove(userId);

    final updated = {...state};
    updated.remove(userId);

    state = updated;
  }
}
