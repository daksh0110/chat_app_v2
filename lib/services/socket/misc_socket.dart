import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';
import 'package:my_app/providers/message_provider.dart';

final miscellaneousNotifierProvider =
    NotifierProvider<MiscellaneousNotifier, void>(MiscellaneousNotifier.new);

class MiscellaneousNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> listenUserUpdateDetails() async {
    final socketService = ref.watch(socketProvider);
    socketService.listenUserUpdateDetails((data) {
      ref.read(messageProvider.notifier).acknowledgeEvent(data);
      ref
          .read(usersTableProvider.notifier)
          .fetchAndUpdateUserProfile(data["user_id"]);
    });
  }
}
