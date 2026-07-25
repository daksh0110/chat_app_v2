import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/group_profile_modal.dart';
import 'package:my_app/modal/user_profile_modal.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/screens/search/user_profile_arguments.dart';
import 'package:my_app/providers/user_profile_provider.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';
import 'package:my_app/widgets/screens/userProfile/media_shared_list.dart';
import 'package:my_app/widgets/screens/userProfile/profile_detail_item.dart';

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => UserProfileState();
}

class UserProfileState extends ConsumerState<UserProfile> {
  SearchItem? user;

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

  Widget _buildGroupProfile(
    BuildContext context,
    GroupProfile group,
    UserProfileArguments args,
    String currentUser,
  ) {
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
          UserBubble(
            profilePicUrl: args.profilePicUrl ?? group.profilePicUrl,
            name: displayName,
            size: 80,
            needActiveIndicator: false,
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
                      if (group.members.isEmpty)
                        const PrimaryText(
                          'No members found',
                          textAlign: TextAlign.center,
                        ),
                      ...group.members.map(
                        (member) => _memberTile(currentUser, member),
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
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 8),
        //     child: ProfileActionButton(
        //       icon: LucideIcons.ellipsis,
        //       onTap: () {},
        //       size: 35,
        //       iconSize: 20,
        //     ),
        //   ),
        // ],
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
          const SizedBox(height: 10),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: const [
          //     ProfileActionButton(icon: LucideIcons.messageCircleMore),
          //     SizedBox(width: 20),
          //     ProfileActionButton(icon: LucideIcons.phone),
          //     SizedBox(width: 20),
          //     ProfileActionButton(icon: LucideIcons.video),
          //   ],
          // ),
          const SizedBox(height: 20),
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

  Widget _memberTile(String? currentUserId, GroupMember member) {
    final isMe = currentUserId == member.userId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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
                const SizedBox(height: 4),
                PrimaryText(
                  member.role == 'ADMIN' ? 'Admin' : 'Member',
                  color: DefaultColorSheet.grey500,
                  fontSize: 14,
                ),
              ],
            ),
          ),
        ],
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
