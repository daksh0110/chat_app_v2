int parseTimestamp(dynamic ts) {
  if (ts == null) return DateTime.now().millisecondsSinceEpoch;
  if (ts is int) return ts;
  if (ts is String) {
    return DateTime.tryParse(ts)?.millisecondsSinceEpoch ??
        int.tryParse(ts) ??
        DateTime.now().millisecondsSinceEpoch;
  }
  if (ts is double) return ts.toInt();
  return DateTime.now().millisecondsSinceEpoch;
}
