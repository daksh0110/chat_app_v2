import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/modal/group_member_added_modal.dart';
import 'package:my_app/modal/group_member_left_modal.dart';
import 'package:my_app/modal/group_member_removed_modal.dart';
import 'package:my_app/modal/group_member_role_updated_modal.dart';
import 'package:my_app/modal/group_modal.dart';
import 'package:my_app/modal/group_profile_updated_modal.dart';
import 'package:my_app/modal/group_sync_modal.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/providers/tables/chat_events_table_provider.dart';
import 'package:my_app/providers/tables/chat_list_table_provider.dart';
import 'package:my_app/providers/tables/chat_participants_table.dart';
import 'package:my_app/providers/tables/groups_table_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';
import 'package:my_app/providers/user_profile_provider.dart';

final groupSocketProvider = NotifierProvider<GroupSocketNotifier, void>(
  GroupSocketNotifier.new,
);

class GroupSocketNotifier extends Notifier<void> {
  bool _isListening = false;

  @override
  void build() {
    _isListening = false;
  }

  void listen() {
    if (_isListening) return;
    _isListening = true;
    final socketService = ref.read(socketProvider);

    // 1. Group member added
    socketService.listen('group-member-added', (data) async {
      try {
        if (data is! Map) return;
        final event = GroupMemberAddedModal.fromJson(
          Map<String, dynamic>.from(data),
        );

        if (event.chatId.isEmpty || event.userId.isEmpty) return;

        final currentUserId = ref.read(userPreferenceTableProvider).value;
        if (currentUserId == null) return;

        final isSelf = event.userId == currentUserId;
        final isActorSelf = event.actorId == currentUserId;
        final db = ref.read(databaseProvider);

        if (isSelf) {
          final groupName = event.group?.name.isNotEmpty == true
              ? event.group!.name
              : 'Group Chat';
          final groupBio = event.group?.bio ?? '';

          await ref.read(chatListTableProvider.notifier).createOrUpdateChatList(
                ChatListModal(
                  id: currentUserId,
                  chatId: event.chatId,
                  lastMessage: event.actorName.isNotEmpty
                      ? '${event.actorName} added you'
                      : 'You were added',
                  lastMessageTime:
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  bio: groupBio,
                  type: 'GROUP',
                ),
              );

          await ref.read(groupsTableProvider.notifier).createOrUpdateGroup(
                GroupModal(
                  id: event.chatId,
                  name: groupName,
                  bio: groupBio,
                ),
              );

          if (event.participants.isNotEmpty) {
            for (final p in event.participants) {
              if (p.name.isNotEmpty) {
                await ref.read(usersTableProvider.notifier).updateUserProfile(
                      UserModel(
                        id: p.userId,
                        name: p.name,
                        email: p.email ?? '',
                        bio: p.bio,
                      ),
                      p.media,
                    );
              }
            }
            await ref
                .read(chatParticipantsTableProvider.notifier)
                .bulkInsertParticipants(event.participants);
          } else {
            await (db.into(db.chatParticipants).insertOnConflictUpdate(
                  ChatParticipantsCompanion.insert(
                    chatId: event.chatId,
                    userId: event.userId,
                    role: Value(event.role),
                  ),
                ));
          }
        } else {
          await (db.into(db.chatParticipants).insertOnConflictUpdate(
                ChatParticipantsCompanion.insert(
                  chatId: event.chatId,
                  userId: event.userId,
                  role: Value(event.role),
                ),
              ));

          if (event.memberName.isNotEmpty) {
            await ref.read(usersTableProvider.notifier).updateUserProfile(
                  UserModel(
                    id: event.userId,
                    name: event.memberName,
                    email: '',
                  ),
                  null,
                );
          }
        }

        await ref
            .read(chatEventsTableProvider.notifier)
            .insertGroupMemberAddedEvent(
              chatId: event.chatId,
              actorName: event.actorName,
              memberName: event.memberName,
              sequence: event.sequence,
              isSelf: isSelf,
              isActorSelf: isActorSelf,
            );

        if (!isSelf) {
          final actionText = isActorSelf
              ? 'You added ${event.memberName}'
              : (event.actorName.isNotEmpty
                  ? '${event.actorName} added ${event.memberName}'
                  : '${event.memberName} joined the group');

          await ref.read(chatListTableProvider.notifier).updateLastMessage(
                chatId: event.chatId,
                lastMessage: actionText,
              );
        }

        ref.invalidate(groupProfile(event.chatId));
      } catch (e) {
        debugPrint('Error handling group-member-added: $e');
      }
    });

    // 2. Group member removed
    socketService.listen('group-member-removed', (data) async {
      try {
        if (data is! Map) return;
        final event = GroupMemberRemovedModal.fromJson(
          Map<String, dynamic>.from(data),
        );

        if (event.chatId.isEmpty || event.userId.isEmpty) return;

        final currentUserId = ref.read(userPreferenceTableProvider).value;
        if (currentUserId == null) return;

        final isSelf = event.userId == currentUserId;
        final isActorSelf = event.actorId == currentUserId;
        final db = ref.read(databaseProvider);

        await (db.delete(db.chatParticipants)
              ..where(
                (tbl) =>
                    tbl.chatId.equals(event.chatId) &
                    tbl.userId.equals(event.userId),
              ))
            .go();

        await ref
            .read(chatEventsTableProvider.notifier)
            .insertGroupMemberRemovedEvent(
              chatId: event.chatId,
              actorName: event.actorName,
              memberName: event.memberName,
              sequence: event.sequence,
              isSelf: isSelf,
              isActorSelf: isActorSelf,
            );

        final actionText = isSelf
            ? (event.actorName.isNotEmpty
                ? '${event.actorName} removed you'
                : 'You were removed')
            : (isActorSelf
                ? 'You removed ${event.memberName}'
                : '${event.actorName} removed ${event.memberName}');

        await ref.read(chatListTableProvider.notifier).updateLastMessage(
              chatId: event.chatId,
              lastMessage: actionText,
            );

        ref.invalidate(groupProfile(event.chatId));
      } catch (e) {
        debugPrint('Error handling group-member-removed: $e');
      }
    });

    // 3. Group member left
    socketService.listen('group-member-left', (data) async {
      try {
        if (data is! Map) return;
        final event = GroupMemberLeftModal.fromJson(
          Map<String, dynamic>.from(data),
        );

        if (event.chatId.isEmpty || event.userId.isEmpty) return;

        final currentUserId = ref.read(userPreferenceTableProvider).value;
        if (currentUserId == null) return;

        final isSelf = event.userId == currentUserId;
        final db = ref.read(databaseProvider);

        await (db.delete(db.chatParticipants)
              ..where(
                (tbl) =>
                    tbl.chatId.equals(event.chatId) &
                    tbl.userId.equals(event.userId),
              ))
            .go();

        await ref
            .read(chatEventsTableProvider.notifier)
            .insertGroupMemberLeftEvent(
              chatId: event.chatId,
              memberName: event.memberName,
              sequence: event.sequence,
              isSelf: isSelf,
            );

        final actionText = isSelf
            ? 'You left the group'
            : '${event.memberName} left the group';

        await ref.read(chatListTableProvider.notifier).updateLastMessage(
              chatId: event.chatId,
              lastMessage: actionText,
            );

        if (event.promotedAdminId != null &&
            event.promotedAdminId!.isNotEmpty) {
          await (db.update(db.chatParticipants)
                ..where(
                  (tbl) =>
                      tbl.chatId.equals(event.chatId) &
                      tbl.userId.equals(event.promotedAdminId!),
                ))
              .write(const ChatParticipantsCompanion(role: Value('ADMIN')));
        }

        ref.invalidate(groupProfile(event.chatId));
      } catch (e) {
        debugPrint('Error handling group-member-left: $e');
      }
    });

    // 4. Group member role updated
    socketService.listen('group-member-role-updated', (data) async {
      try {
        if (data is! Map) return;
        final event = GroupMemberRoleUpdatedModal.fromJson(
          Map<String, dynamic>.from(data),
        );

        if (event.chatId.isEmpty || event.userId.isEmpty) return;

        final currentUserId = ref.read(userPreferenceTableProvider).value;
        if (currentUserId == null) return;

        final isSelf = event.userId == currentUserId;
        final isActorSelf = event.actorId == currentUserId;
        final db = ref.read(databaseProvider);

        await (db.update(db.chatParticipants)
              ..where(
                (tbl) =>
                    tbl.chatId.equals(event.chatId) &
                    tbl.userId.equals(event.userId),
              ))
            .write(ChatParticipantsCompanion(role: Value(event.role)));

        await ref
            .read(chatEventsTableProvider.notifier)
            .insertGroupMemberRoleUpdatedEvent(
              chatId: event.chatId,
              actorName: event.actorName,
              memberName: event.memberName,
              role: event.role,
              sequence: event.sequence,
              isSelf: isSelf,
              isActorSelf: isActorSelf,
            );

        final roleStr = event.role.toLowerCase() == 'admin' ? 'an admin' : 'a member';
        final actionText = isActorSelf
            ? 'You made ${event.memberName} $roleStr'
            : (isSelf
                ? '${event.actorName} made you $roleStr'
                : '${event.actorName} made ${event.memberName} $roleStr');

        await ref.read(chatListTableProvider.notifier).updateLastMessage(
              chatId: event.chatId,
              lastMessage: actionText,
            );

        ref.invalidate(groupProfile(event.chatId));
      } catch (e) {
        debugPrint('Error handling group-member-role-updated: $e');
      }
    });

    // 5. Group sync
    socketService.listen('group-sync', (data) async {
      try {
        if (data is! Map) return;
        final event = GroupSyncModal.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (event.chatId.isEmpty) return;

        await ref.read(groupsTableProvider.notifier).createOrUpdateGroup(
              GroupModal(
                id: event.chatId,
                name: event.name,
                bio: event.description,
                profilePic: event.profilePicUrl.isNotEmpty
                    ? event.profilePicUrl
                    : null,
              ),
            );

        if (event.participants.isNotEmpty) {
          for (final p in event.participants) {
            if (p.name.isNotEmpty) {
              await ref.read(usersTableProvider.notifier).updateUserProfile(
                    UserModel(
                      id: p.userId,
                      name: p.name,
                      email: p.email ?? '',
                      bio: p.bio,
                    ),
                    p.media,
                  );
            }
          }
          await ref
              .read(chatParticipantsTableProvider.notifier)
              .bulkInsertParticipants(event.participants);
        }

        ref.invalidate(groupProfile(event.chatId));
      } catch (e) {
        debugPrint('Error handling group-sync: $e');
      }
    });

    // 6. Group profile updated (photo, name, bio)
    socketService.listen('group-profile-updated', (data) async {
      try {
        if (data is! Map) return;
        final event = GroupProfileUpdatedModal.fromJson(
          Map<String, dynamic>.from(data),
        );

        if (event.chatId.isEmpty) return;

        final currentUserId = ref.read(userPreferenceTableProvider).value;
        final isActorSelf =
            event.actorId.isNotEmpty && event.actorId == currentUserId;

        final db = ref.read(databaseProvider);
        final existingGroup = await (db.select(db.groupListTable)
              ..where((t) => t.chatId.equals(event.chatId)))
            .getSingleOrNull();

        final updatedName = (event.name != null && event.name!.isNotEmpty)
            ? event.name!
            : (existingGroup?.name ?? 'Group Chat');
        final updatedBio = event.bio ?? existingGroup?.bio ?? '';

        await ref.read(groupsTableProvider.notifier).createOrUpdateGroup(
              GroupModal(
                id: event.chatId,
                name: updatedName,
                bio: updatedBio,
                media: event.media,
              ),
            );

        ref.invalidate(groupProfile(event.chatId));

        await ref
            .read(chatEventsTableProvider.notifier)
            .insertGroupProfileUpdatedEvent(
              chatId: event.chatId,
              actorName: event.actorName,
              sequence: event.sequence,
              isActorSelf: isActorSelf,
            );

        final actionText = isActorSelf
            ? 'You updated the group profile'
            : (event.actorName.isNotEmpty
                ? '${event.actorName} updated the group profile'
                : 'Group profile updated');

        await ref.read(chatListTableProvider.notifier).updateLastMessage(
              chatId: event.chatId,
              lastMessage: actionText,
            );
      } catch (e) {
        debugPrint('Error handling group-profile-updated: $e');
      }
    });
  }
}

