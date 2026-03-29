import 'package:intl/intl.dart';

String getDateLabel(int timestamp) {
  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

  final today = DateTime(now.year, now.month, now.day);
  final msgDate = DateTime(date.year, date.month, date.day);

  final diff = today.difference(msgDate).inDays;

  if (diff == 0) return "Today";
  if (diff == 1) return "Yesterday";
  if (diff < 7) return DateFormat('EEEE').format(date);

  return DateFormat('MMM d, yyyy').format(date);
}
