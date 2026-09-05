import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/request_user_provider.dart';
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

  @override
  Future<RelationshipStatus> build() async {
    final requestProvider = ref.read(requestUserProvider.notifier);

    return requestProvider.getRelationshipStatus(userId);
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

      state = AsyncError(Exception(response.message), StackTrace.current);
    } catch (e, stackTrace) {
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
        state = AsyncError(Exception(response.message), StackTrace.current);
        return;
      }

      await ref
          .read(requestUserProvider.notifier)
          .insertOrUpdateRequest(userId, 'FRIENDS');

      state = const AsyncData(RelationshipStatus.friends);
    } catch (e, stackTrace) {
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

      final db = ref.read(databaseProvider);
      await db
          .into(db.friendsTable)
          .insertOnConflictUpdate(
            FriendsTableCompanion(
              userId: Value(userId),
              status: const Value('BLOCKED'),
            ),
          );
      state = const AsyncData(RelationshipStatus.blocked);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
