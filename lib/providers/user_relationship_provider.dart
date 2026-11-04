import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/blocks_table_provider.dart';
import 'package:my_app/providers/tables/chat_events_table_provider.dart';
import 'package:my_app/providers/tables/chat_list_table_provider.dart';
import 'package:my_app/providers/tables/request_user_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';
import 'package:my_app/providers/token_provider.dart';

enum RelationshipStatus {
  none,
  pendingOutgoing,
  pendingIncoming,
  friends,
  blocked,
}

final userRelationshipProvider =
    AsyncNotifierProvider.family<
      UserRelationshipNotifier,
      RelationshipStatus,
      String
    >(UserRelationshipNotifier.new);

class UserRelationshipNotifier extends AsyncNotifier<RelationshipStatus> {
  UserRelationshipNotifier(this.userId);

  final String userId;
  StreamSubscription? _friendSub;
  StreamSubscription? _blockSub;

  @override
  Future<RelationshipStatus> build() async {
    final db = ref.read(databaseProvider);

    _friendSub?.cancel();
    _blockSub?.cancel();

    _friendSub = (db.select(db.friendsTable)..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull()
        .listen((_) {
      _recomputeFromDb();
    });

    _blockSub = (db.select(db.blocksTable)..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull()
        .listen((_) {
      _recomputeFromDb();
    });

    ref.onDispose(() {
      _friendSub?.cancel();
      _blockSub?.cancel();
    });

    // Background fetch to ensure local state is in sync with backend
    Future.microtask(() {
      ref.read(usersTableProvider.notifier).fetchAndUpdateUserProfile(userId);
    });

    final requestProvider = ref.read(requestUserProvider.notifier);
    return requestProvider.getRelationshipStatus(userId);
  }

  Future<void> _recomputeFromDb() async {
    try {
      final status = await ref
          .read(requestUserProvider.notifier)
          .getRelationshipStatus(userId);
      state = AsyncData(status);
    } catch (_) {}
  }

  Future<void> sendFriendRequest() async {
    state = const AsyncLoading();

    try {
      final token = ref.read(tokenProvider).value;

      if (token == null) {
        state = AsyncError(
          Exception('Authentication token not found'),
          StackTrace.current,
        );
        return;
      }

      final response = await UserApiService(
        ApiClient(),
      ).sendFriendRequest(token: token, targetUserId: userId);

      if (response.success) {
        await ref
            .read(requestUserProvider.notifier)
            .insertOrUpdateRequest(userId, 'PENDING_OUTGOING');

        state = const AsyncData(RelationshipStatus.pendingOutgoing);
        return;
      }

      final errorMsg = response.message.toLowerCase();
      if (errorMsg.contains('already exist') ||
          errorMsg.contains('already friends') ||
          errorMsg.contains('already a friend')) {
        await ref
            .read(requestUserProvider.notifier)
            .insertOrUpdateRequest(userId, 'FRIENDS');
        await ref
            .read(usersTableProvider.notifier)
            .fetchAndUpdateUserProfile(userId);
        state = const AsyncData(RelationshipStatus.friends);
        return;
      } else if (errorMsg.contains('already sent') ||
          errorMsg.contains('pending') ||
          errorMsg.contains('request already')) {
        await ref
            .read(requestUserProvider.notifier)
            .insertOrUpdateRequest(userId, 'PENDING_OUTGOING');
        state = const AsyncData(RelationshipStatus.pendingOutgoing);
        return;
      }

      state = AsyncError(Exception(response.message), StackTrace.current);
    } catch (e, stackTrace) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('already exist') ||
          errorStr.contains('already friends') ||
          errorStr.contains('already a friend')) {
        await ref
            .read(requestUserProvider.notifier)
            .insertOrUpdateRequest(userId, 'FRIENDS');
        await ref
            .read(usersTableProvider.notifier)
            .fetchAndUpdateUserProfile(userId);
        state = const AsyncData(RelationshipStatus.friends);
        return;
      } else if (errorStr.contains('already sent') ||
          errorStr.contains('pending') ||
          errorStr.contains('request already')) {
        await ref
            .read(requestUserProvider.notifier)
            .insertOrUpdateRequest(userId, 'PENDING_OUTGOING');
        state = const AsyncData(RelationshipStatus.pendingOutgoing);
        return;
      }
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> acceptFriendRequest() async {
    state = const AsyncLoading();

    try {
      final token = ref.read(tokenProvider).value;
      if (token == null) {
        state = AsyncError(
          Exception('Authentication token not found'),
          StackTrace.current,
        );
        return;
      }

      final response = await UserApiService(
        ApiClient(),
      ).acceptFriendRequest(token: token, targetUserId: userId);

      if (!response.success) {
        final errorMsg = response.message.toLowerCase();
        if (errorMsg.contains('already') || errorMsg.contains('accepted')) {
          await ref
              .read(requestUserProvider.notifier)
              .insertOrUpdateRequest(userId, 'FRIENDS');
          state = const AsyncData(RelationshipStatus.friends);
          return;
        }
        state = AsyncError(Exception(response.message), StackTrace.current);
        return;
      }

      await ref
          .read(requestUserProvider.notifier)
          .insertOrUpdateRequest(userId, 'FRIENDS');

      // Record timeline event in chat if chat exists or local chat
      final user =
          await ref.read(usersTableProvider.notifier).getUserById(userId);
      final chatId = await ref
              .read(chatListTableProvider.notifier)
              .findDirectChatIdWithUser(userId) ??
          "local_$userId";
      await ref.read(chatEventsTableProvider.notifier).insertFriendAddedEvent(
            chatId: chatId,
            friendName: user?.name ?? "",
          );

      state = const AsyncData(RelationshipStatus.friends);
    } catch (e, stackTrace) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('already') || errorStr.contains('accepted')) {
        await ref
            .read(requestUserProvider.notifier)
            .insertOrUpdateRequest(userId, 'FRIENDS');
        state = const AsyncData(RelationshipStatus.friends);
        return;
      }
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> rejectFriendRequest() async {
    state = const AsyncLoading();

    try {
      final token = ref.read(tokenProvider).value;
      if (token == null) {
        state = AsyncError(
          Exception('Authentication token not found'),
          StackTrace.current,
        );
        return;
      }

      final response = await UserApiService(
        ApiClient(),
      ).rejectFriendRequest(token: token, targetUserId: userId);

      if (!response.success) {
        state = AsyncError(Exception(response.message), StackTrace.current);
        return;
      }

      await ref
          .read(requestUserProvider.notifier)
          .insertOrUpdateRequest(userId, 'NONE');

      state = const AsyncData(RelationshipStatus.none);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> removeFriendRequest() async {
    final previousStatus = state.asData?.value;
    state = const AsyncLoading();
    try {
      final token = ref.read(tokenProvider).value;
      if (token == null) {
        state = AsyncError(
          Exception('Authentication token not found'),
          StackTrace.current,
        );
        return;
      }
      final response = previousStatus == RelationshipStatus.pendingOutgoing
          ? await UserApiService(
              ApiClient(),
            ).cancelFriendRequest(token: token, targetUserId: userId)
          : await UserApiService(
              ApiClient(),
            ).removeFriend(token: token, targetUserId: userId);

      if (!response.success) {
        state = AsyncError(Exception(response.message), StackTrace.current);
        return;
      }

      await ref
          .read(requestUserProvider.notifier)
          .insertOrUpdateRequest(userId, 'NONE');
      state = const AsyncData(RelationshipStatus.none);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> blockUser() async {
    state = const AsyncLoading();
    try {
      final token = ref.read(tokenProvider).value;
      if (token == null) {
        state = AsyncError(
          Exception('Authentication token not found'),
          StackTrace.current,
        );
        return;
      }

      final response = await UserApiService(
        ApiClient(),
      ).blockUser(token: token, targetUserId: userId);

      if (!response.success) {
        state = AsyncError(Exception(response.message), StackTrace.current);
        return;
      }

      await ref.read(blocksTableProvider.notifier).blockUser(userId);

      // Record timeline event in chat if chat exists or local chat
      final chatId = await ref
              .read(chatListTableProvider.notifier)
              .findDirectChatIdWithUser(userId) ??
          "local_$userId";
      await ref
          .read(chatEventsTableProvider.notifier)
          .insertUserBlockedEvent(chatId: chatId);

      state = const AsyncData(RelationshipStatus.blocked);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> unblockUser() async {
    state = const AsyncLoading();
    try {
      final token = ref.read(tokenProvider).value;
      if (token == null) {
        state = AsyncError(
          Exception('Authentication token not found'),
          StackTrace.current,
        );
        return;
      }

      final response = await UserApiService(
        ApiClient(),
      ).unblockUser(token: token, targetUserId: userId);

      if (!response.success) {
        state = AsyncError(Exception(response.message), StackTrace.current);
        return;
      }

      await ref.read(blocksTableProvider.notifier).unblockUser(userId);

      // Record timeline event in chat if chat exists or local chat
      final chatId = await ref
              .read(chatListTableProvider.notifier)
              .findDirectChatIdWithUser(userId) ??
          "local_$userId";
      await ref
          .read(chatEventsTableProvider.notifier)
          .insertUserUnblockedEvent(chatId: chatId);

      final currentRelationship = await ref
          .read(requestUserProvider.notifier)
          .getRelationshipStatus(userId);
      state = AsyncData(currentRelationship);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
