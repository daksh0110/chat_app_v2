import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/user_profile_info_procider.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/screens/search/user_profile_arguments.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';
import 'package:my_app/widgets/screens/userProfile/profile_action_button.dart';
import 'package:my_app/widgets/screens/userProfile/profile_detail_item.dart';

final groupProfileProvider = FutureProvider.family<GroupProfile, String>((
  ref,
  chatId,
) async {
  final db = ref.read(databaseProvider);
  final chat = await db.managers.chatListTable
      .filter((f) => f.chatId.equals(chatId))
      .getSingleOrNull();
  final participants = await db.managers.chatParticipants
      .filter((f) => f.chatId.equals(chatId))
      .get();

  return GroupProfile(
    chatId: chatId,
    name: chat?.name ?? '',
    description: chat?.description ?? '',
    profilePicUrl: chat?.profilePicUrl,
    members: participants
        .map(
          (p) => GroupMember(
            userId: p.userId,
            name: p.name,
            profilePicUrl: p.profilePicUrl,
            role: p.role,
          ),
        )
        .toList(),
  );
});

class GroupProfile {
  final String chatId;
  final String name;
  final String description;
  final String? profilePicUrl;
  final List<GroupMember> members;

  GroupProfile({
    required this.chatId,
    required this.name,
    required this.description,
    this.profilePicUrl,
    required this.members,
  });
}

class GroupMember {
  final String userId;
  final String name;
  final String? profilePicUrl;
  final String role;

  GroupMember({
    required this.userId,
    required this.name,
    this.profilePicUrl,
    required this.role,
  });
}

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => UserProfileState();
}

class UserProfileState extends ConsumerState<UserProfile> {
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
      final groupArgs = routeArgs as UserProfileArguments;
      return ref
          .watch(groupProfileProvider(id))
          .when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) =>
                Scaffold(body: Center(child: Text('Error: $err'))),
            data: (group) => _buildGroupProfile(context, group, groupArgs),
          );
    }

    return ref
        .watch(userProfileProvider(id))
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) =>
              Scaffold(body: Center(child: Text('Error: $err'))),
          data: _buildUserProfile,
        );
  }

  Widget _buildGroupProfile(
    BuildContext context,
    GroupProfile group,
    UserProfileArguments args,
  ) {
    final currentUser = ref.watch(settingsUserProvider);
    final displayName = args.name?.isNotEmpty == true
        ? args.name!
        : group.name.isNotEmpty
        ? group.name
        : 'Group Chat';
    final adminCount = group.members
        .where((member) => member.role.toUpperCase() == 'ADMIN')
        .length;

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
                      ProfileDetailItem(title: 'Admins', value: '$adminCount'),
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
                        (member) => _memberTile(currentUser?.id, member),
                      ),
                      const SizedBox(height: 12),
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

  Widget _buildUserProfile(SearchItem info) {
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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ProfileActionButton(
              icon: LucideIcons.ellipsis,
              onTap: () {},
              size: 35,
              iconSize: 20,
            ),
          ),
        ],
      ),
      body: _buildProfileBody(
        children: [
          const SizedBox(height: 10),
          UserBubble(
            profilePicUrl: info.profilePicUrl,
            name: info.name,
            size: 80,
            needActiveIndicator: false,
          ),
          const SizedBox(height: 10),
          PrimaryText(
            info.name,
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              ProfileActionButton(icon: LucideIcons.messageCircleMore),
              SizedBox(width: 20),
              ProfileActionButton(icon: LucideIcons.phone),
              SizedBox(width: 20),
              ProfileActionButton(icon: LucideIcons.video),
            ],
          ),
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
                      ProfileDetailItem(title: 'Name', value: info.name),
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
                              'View all',
                              color: DefaultColorSheet.green500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const PrimaryText(
                        'No media found',
                        textAlign: TextAlign.center,
                      ),
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
