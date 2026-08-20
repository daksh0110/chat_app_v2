import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/modal/global_queue.dart';

final globalQueueProvider =
    NotifierProvider<GlobalQueueProvider, List<QueueItem>>(
      GlobalQueueProvider.new,
    );

class GlobalQueueProvider extends Notifier<List<QueueItem>> {
  bool _isProcessingQueue = false;

  @override
  List<QueueItem> build() {
    return [];
  }

  void add<T extends Object>({
    required T value,
    required Future<void> Function(T value) process,
  }) {
    state = [
      ...state,
      QueueItem(value: value, process: (Object value) => process(value as T)),
    ];

    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;

    _isProcessingQueue = true;

    try {
      while (true) {
        final item = _getNext();

        if (item == null) {
          break;
        }

        _setProcessing(item, true);

        try {
          await item.process(item.value);
        } catch (e) {
          debugPrint('Error processing queue item: $e');
        }

        _remove(item);
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  QueueItem? _getNext() {
    for (final item in state) {
      if (!item.processing) {
        return item;
      }
    }

    return null;
  }

  void _setProcessing(QueueItem item, bool processing) {
    final index = state.indexOf(item);

    if (index == -1) return;

    state = [
      ...state.sublist(0, index),
      QueueItem(
        value: item.value,
        process: item.process,
        processing: processing,
      ),
      ...state.sublist(index + 1),
    ];
  }

  void _remove(QueueItem item) {
    state = state.where((element) => element != item).toList();
  }
}
