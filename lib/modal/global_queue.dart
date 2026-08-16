class QueueItem {
  final Object value;
  final Future<void> Function(Object value) process;
  final bool processing;

  QueueItem({
    required this.value,
    required this.process,
    this.processing = false,
  });
}
