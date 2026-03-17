import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/services/socker_service.dart';

final socketProvider = Provider<SocketService>((ref) {
  return SocketService();
});
