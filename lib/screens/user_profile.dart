import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/util/get_file_type.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/screens/select_members_screen.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/user_relationship_provider.dart';
import 'package:my_app/modal/group_profile_modal.dart';
import 'package:my_app/modal/user_profile_modal.dart';
import 'package:my_app/providers/tables/groups_table_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/screens/search/user_profile_arguments.dart';
import 'package:my_app/providers/user_profile_provider.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';
import 'package:my_app/widgets/screens/userProfile/build_relationship_button.dart';
import 'package:my_app/widgets/screens/userProfile/media_shared_list.dart';
import 'package:my_app/widgets/screens/userProfile/profile_detail_item.dart';
import 'package:toastification/toastification.dart';

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => UserProfileState();
}

class UserProfileState extends ConsumerState<UserProfile> {
  SearchItem? user;
  String? _refreshedProfileId;
  bool _isUpdatingGroupPhoto = false;

  Future<void> _updateGroupPhoto(BuildContext context, String chatId) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedImage == null) return;

      setState(() {
        _isUpdatingGroupPhoto = true;
      });

      final mime =
          lookupMimeType(pickedImage.path) ?? 'application/octet-stream';

      final presignedUrl = await UploadService(ApiClient()).getPresignedUrl(
        assetType: 'chat',
        entityType: 'avatar',
        contentType: mime,
      );

      if (!presignedUrl.success || presignedUrl.data == null) {
        throw Exception('Unable to generate presigned URL');
      }

      final response = presignedUrl.data!;
      final result = await UploadService(ApiClient()).uploadToSignedUrl(
        await pickedImage.readAsBytes(),
        response.url,
        mime,
      );

      if (result != 200) {
        throw Exception('Failed to upload image file');
      }

      await ref.read(socketProvider).updateGroupProfile(
        chatId: chatId,
        media: {
          'key': response.key ?? '',
          'name': pickedImage.name,
          'type': getMediaType(mime),
          'content_type': mime,
        },
        image: response.key ?? '',
      );

      if (context.mounted) {
        ToastHelper.show(
          context: context,
          message: 'Group photo updated successfully',
          type: ToastificationType.success,
        );
      }
    } catch (e) {
      debugPrint('Failed to update group photo: $e');
      if (context.mounted) {
        ToastHelper.show(
          context: context,
          message: 'Failed to update group photo: $e',
          type: ToastificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingGroupPhoto = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is! UserProfileArguments) return;

    final profileId = routeArgs.id;
    if (_refreshedProfileId == profileId) return;

    _refreshedProfileId = profileId;
    if (routeArgs.isGroupChat) {
      Future.microtask(() async {
        try {
          await ref
              .read(groupsTableProvider.notifier)
              .fetchAndUpdateGroup(profileId);
          ref.invalidate(groupProfile(profileId));
        } catch (_) {}
      });
    } else {
      ref.invalidate(userProfile(profileId));
      ref.invalidate(userRelationshipProvider(profileId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)!.settings.arguments;
    final isGroupChat = routeArgs is UserProfileArguments
        ? routeArgs.isGroupChat
        : false;
    final id = routeArgs is UserProfileArguments
        ? routeArgs.id
        : routeArgs as String;

    if (isGroupChat) {
      final groupArgs = routeArgs;
      final currentUser = ref.watch(userPreferenceTableProvider).value;
      return ref
          .watch(groupProfile(id))
          .when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => Scaffold(body: Center(child: Text(e.toString()))),
            data: (group) {
              return _buildGroupProfile(
                context,
                group!,
                groupArgs,
                currentUser ?? "",
              );
            },
          );
    }

    return ref
        .watch(userProfile(id))
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) =>
              Scaffold(body: Center(child: Text('Error: $err'))),
          data: (info) {
            if (info == null) {
              return const Scaffold(
                body: Center(child: Text("User not found")),
              );
            }
            return _buildUserProfile(info);
          },
        );
  }

  void _showLeaveGroupDialog(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Leave Group', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to leave this group?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(socketProvider).leaveGroup(chatId);
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              } catch (e) {
                if (context.mounted) {
                  ToastHelper.show(
                    context: context,
                    message: e.toString().replaceFirst('Exception: ', ''),
                    type: ToastificationType.error,
                  );
                }
              }
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, String chatId, GroupMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('Remove ${member.name}', style: const TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove ${member.name} from this group?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(socketProvider).removeGroupMember(chatId, member.userId);
              } catch (e) {
                if (context.mounted) {
                  ToastHelper.show(
                    context: context,
                    message: e.toString().replaceFirst('Exception: ', ''),
                    type: ToastificationType.error,
                  );
                }
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupProfile(
    BuildContext context,
    GroupProfile group,
    UserProfileArguments args,
    String currentUser,
  ) {
    final isCurrentUserAdmin = group.members.any(
      (m) => m.userId == currentUser && m.role.toUpperCase() == 'ADMIN',
    );
    final displayName = args.name?.isNotEmpty == true
        ? args.name!
        : group.name.isNotEmpty
        ? group.name
        : 'Group Chat';
    final adminCount = group.members
        .where((member) => member.role.toUpperCase() == 'ADMIN')
        .length;
    final media = group.mediaShared;
    final mediaCount = group.totalMediaCount;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 60,
        actionsPadding: const EdgeInsets.only(right: 16),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: _buildProfileBody(
        children: [
          const SizedBox(height: 10),
          GestureDetector(
            onTap: isCurrentUserAdmin && !_isUpdatingGroupPhoto
                ? () => _updateGroupPhoto(context, group.chatId)
                : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                UserBubble(
                  profilePicUrl: args.profilePicUrl ?? group.profilePicUrl,
                  name: displayName,
                  size: 80,
                  needActiveIndicator: false,
                ),
                if (isCurrentUserAdmin)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: DefaultColorSheet.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: _isUpdatingGroupPhoto
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          PrimaryText(
            displayName,
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          PrimaryText(
            '${group.members.length} members · $adminCount admin${adminCount == 1 ? '' : 's'}',
            color: Colors.white70,
            fontSize: 14,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PrimaryContainer(
              children: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileDetailItem(
                        title: 'Group Name',
                        value: displayName,
                      ),
                      ProfileDetailItem(
                        title: 'Description',
                        value: group.description.isNotEmpty
                            ? group.description
                            : '--',
                      ),
                      ProfileDetailItem(
                        title: 'Members',
                        value: '${group.members.length} participants',
                      ),
                      const PrimaryText(
                        'Group Members',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: DefaultColorSheet.grey500,
                      ),
                      const SizedBox(height: 14),
                      if (isCurrentUserAdmin) ...[
                        InkWell(
                          onTap: () async {
                            final excluded = group.members.map((m) => m.userId).toList();
                            final List<UserModel>? selected = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectMembersScreen(
                                  initialSelected: const [],
                                  excludedUserIds: excluded,
                                ),
                              ),
                            );
                            if (selected != null && selected.isNotEmpty && context.mounted) {
                              final socket = ref.read(socketProvider);
                              for (final user in selected) {
                                try {
                                  await socket.addGroupMember(group.chatId, user.id);
                                } catch (e) {
                                  if (context.mounted) {
                                    ToastHelper.show(
                                      context: context,
                                      message: e.toString().replaceFirst('Exception: ', ''),
                                      type: ToastificationType.error,
                                    );
                                  }
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: DefaultColorSheet.primary.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    LucideIcons.userPlus,
                                    color: DefaultColorSheet.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const PrimaryText(
                                  'Add Members',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: DefaultColorSheet.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (group.members.isEmpty)
                        const PrimaryText(
                          'No members found',
                          textAlign: TextAlign.center,
                        ),
                      ...group.members.map(
                        (member) => _memberTile(
                          currentUser,
                          member,
                          isCurrentUserAdmin,
                          group.chatId,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          PrimaryText(
                            'Media Shared',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: DefaultColorSheet.grey500,
                          ),
                          const Spacer(),
                          InkWell(
                            child: PrimaryText(
                              mediaCount > media.length
                                  ? 'View all ($mediaCount)'
                                  : 'View all',
                              color: DefaultColorSheet.green500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (media.isEmpty) ...[
                        const PrimaryText(
                          'No media found',
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        MediaSharedList(media: media),
                      ],
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () => _showLeaveGroupDialog(context, group.chatId),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.logOut,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              PrimaryText(
                                'Leave Group',
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(UserProfileModal info) {
    final media = info.mediaShared;
    final mediaCount = info.totalMediaCount;
    final relationshipProvider = userRelationshipProvider(info.id ?? "");

    final relationshipStatus = ref.watch(relationshipProvider);

    final relationshipNotifier = ref.read(relationshipProvider.notifier);

    ref.listen(relationshipProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ToastHelper.show(
            context: context,
            message: error.toString().replaceFirst('Exception: ', ''),
            type: ToastificationType.error,
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 60,
        actionsPadding: const EdgeInsets.only(right: 16),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.ellipsisVertical, color: Colors.white),
            color: Colors.grey[900],
            onSelected: (value) {
              if (value == 'block') {
                relationshipNotifier.blockUser();
              } else if (value == 'unblock') {
                relationshipNotifier.unblockUser();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: relationshipStatus.value == RelationshipStatus.blocked
                    ? 'unblock'
                    : 'block',
                child: Text(
                  relationshipStatus.value == RelationshipStatus.blocked
                      ? 'Unblock'
                      : 'Block',
                  style: TextStyle(
                    color:
                        relationshipStatus.value == RelationshipStatus.blocked
                        ? Colors.white
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildProfileBody(
        children: [
          const SizedBox(height: 10),
          UserBubble(
            profilePicUrl: info.profilePic,
            name: info.name ?? "",
            size: 80,
            needActiveIndicator: false,
          ),
          const SizedBox(height: 10),
          PrimaryText(
            info.name ?? "",
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 18),
          buildRelationshipButton(
            relationshipStatus.value ?? RelationshipStatus.none,
            relationshipNotifier,
            relationshipStatus.isLoading,
            context: context,
            userName: info.name ?? "User",
            profilePicUrl: info.profilePic,
            onMessageTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.message,
                arguments: MessageScreenArguments(
                  receiverId: info.id ?? "",
                  name: info.name ?? "",
                  profilePicUrl: info.profilePic,
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          Expanded(
            child: PrimaryContainer(
              children: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileDetailItem(title: 'Name', value: info.name ?? ""),
                      ProfileDetailItem(
                        title: 'Email',
                        value: info.email ?? '',
                      ),
                      ProfileDetailItem(
                        title: 'Bio',
                        value: info.bio?.isNotEmpty == true
                            ? info.bio ?? ''
                            : '--',
                      ),
                      Row(
                        children: [
                          PrimaryText(
                            'Media Shared',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: DefaultColorSheet.grey500,
                          ),
                          const Spacer(),
                          InkWell(
                            child: PrimaryText(
                              mediaCount > media.length
                                  ? 'View all ($mediaCount)'
                                  : 'View all',
                              color: DefaultColorSheet.green500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (media.isEmpty) ...[
                        const PrimaryText(
                          'No media found',
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        MediaSharedList(media: media),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMemberOptionsSheet(
    BuildContext context,
    String chatId,
    GroupMember member,
    bool isMemberAdmin,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: UserBubble(
                  profilePicUrl: member.profilePicUrl,
                  name: member.name,
                  size: 44,
                  needActiveIndicator: false,
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  isMemberAdmin ? 'Group Admin' : 'Group Member',
                  style: TextStyle(
                    color: isMemberAdmin
                        ? DefaultColorSheet.primary
                        : Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: Icon(
                  isMemberAdmin
                      ? LucideIcons.shieldAlert
                      : LucideIcons.shieldCheck,
                  color: Colors.white,
                ),
                title: Text(
                  isMemberAdmin ? 'Dismiss as admin' : 'Make group admin',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final socket = ref.read(socketProvider);
                  final newRole = isMemberAdmin ? 'MEMBER' : 'ADMIN';
                  try {
                    await socket.changeGroupMemberRole(
                      chatId,
                      member.userId,
                      newRole,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ToastHelper.show(
                        context: context,
                        message: e.toString().replaceFirst('Exception: ', ''),
                        type: ToastificationType.error,
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  LucideIcons.userMinus,
                  color: Colors.redAccent,
                ),
                title: Text(
                  'Remove ${member.name} from group',
                  style: const TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showRemoveMemberDialog(context, chatId, member);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _memberTile(
    String? currentUserId,
    GroupMember member,
    bool isCurrentUserAdmin,
    String chatId,
  ) {
    final isMe = currentUserId == member.userId;
    final isMemberAdmin = member.role.toUpperCase() == 'ADMIN';

    return InkWell(
      onTap: (isCurrentUserAdmin && !isMe)
          ? () => _showMemberOptionsSheet(
                context,
                chatId,
                member,
                isMemberAdmin,
              )
          : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            UserBubble(
              profilePicUrl: member.profilePicUrl,
              name: member.name,
              size: 40,
              needActiveIndicator: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryText(
                    isMe ? '${member.name} (You)' : member.name,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 3),
                  if (isMemberAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: DefaultColorSheet.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(
                          color: DefaultColorSheet.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const PrimaryText(
                      'Member',
                      color: DefaultColorSheet.grey500,
                      fontSize: 13,
                    ),
                ],
              ),
            ),
            if (isCurrentUserAdmin && !isMe)
              IconButton(
                icon: const Icon(
                  LucideIcons.ellipsisVertical,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () => _showMemberOptionsSheet(
                  context,
                  chatId,
                  member,
                  isMemberAdmin,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBody({required List<Widget> children}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: children,
      ),
    );
  }
}
