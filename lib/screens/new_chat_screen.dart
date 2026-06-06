import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';

class NewChatScreen extends ConsumerWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DefaultColorSheet.lightBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const PrimaryText(
          'New Chat',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DefaultColorSheet.lightBlack,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: DefaultColorSheet.grey200,
            height: 1,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.createGroupChat),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: DefaultColorSheet.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.users,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      PrimaryText(
                        'New Group',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DefaultColorSheet.primary,
                      ),
                      SizedBox(height: 2),
                      PrimaryText(
                        'Create a group chat',
                        fontSize: 13,
                        color: DefaultColorSheet.grey500,
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: DefaultColorSheet.grey400,
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 1,
            color: DefaultColorSheet.grey200,
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: PrimaryText(
              'All Contacts',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DefaultColorSheet.grey500,
            ),
          ),

          Expanded(
            child: StreamBuilder<List<UsersTableData>>(
              stream: db.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.userX,
                          size: 48,
                          color: DefaultColorSheet.grey400,
                        ),
                        const SizedBox(height: 12),
                        const PrimaryText(
                          'No contacts yet',
                          fontSize: 15,
                          color: DefaultColorSheet.grey500,
                        ),
                        const SizedBox(height: 6),
                        const PrimaryText(
                          'Search to find people to chat with',
                          fontSize: 13,
                          color: DefaultColorSheet.grey400,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(left: 86),
                    child: Container(height: 1, color: DefaultColorSheet.grey200),
                  ),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _ContactTile(user: user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final UsersTableData user;
  const _ContactTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.message,
          arguments: MessageScreenArguments(
            receiverId: user.id,
            name: user.name,
            profilePicUrl: user.profilePictureUrl,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            UserBubble(
              profilePicUrl: user.profilePictureUrl,
              name: user.name,
              size: 50,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryText(
                    user.name,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: DefaultColorSheet.lightBlack,
                  ),
                  if (user.email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    PrimaryText(
                      user.email,
                      fontSize: 13,
                      color: DefaultColorSheet.grey500,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: DefaultColorSheet.grey400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
