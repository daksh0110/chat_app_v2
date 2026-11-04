import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/screens/settings/blocked_user_model.dart';
import 'package:my_app/providers/tables/blocks_table_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';
import 'package:my_app/providers/user_relationship_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';

class BlockedUsersScreen extends ConsumerStatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  ConsumerState<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<BlockedUsersScreen> {
  final Set<String> _fetchedUsers = {};

  void _maybeFetchUserProfile(String userId, String currentName) {
    if (currentName == "User" && !_fetchedUsers.contains(userId)) {
      _fetchedUsers.add(userId);
      Future.microtask(() {
        ref.read(usersTableProvider.notifier).fetchAndUpdateUserProfile(userId);
      });
    }
  }

  Future<void> _confirmAndUnblock(BlockedUserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Unblock ${user.name}?"),
        content: const Text(
          "They will be able to send you messages and call you.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: DefaultColorSheet.green400,
            ),
            child: const Text(
              "Unblock",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(userRelationshipProvider(user.userId).notifier)
            .unblockUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${user.name} has been unblocked"),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to unblock: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockedAsync = ref.watch(blockedUsersProvider);

    return Scaffold(
      backgroundColor: DefaultColorSheet.scaffoldBg(context),
      appBar: AppBar(
        backgroundColor: DefaultColorSheet.appBarBg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: DefaultColorSheet.appBarIcon(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: PrimaryText(
          "Blocked Contacts",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DefaultColorSheet.appBarTitle(context),
        ),
        centerTitle: true,
      ),
      body: blockedAsync.when(
        data: (blockedUsers) {
          if (blockedUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block_outlined,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  PrimaryText(
                    "No blocked contacts",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Contacts you block will appear here. They won't be able to message you or see your online status.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: blockedUsers.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey.shade100, height: 16),
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              _maybeFetchUserProfile(user.userId, user.name);

              final subtitleText = user.bio != null && user.bio!.isNotEmpty
                  ? user.bio!
                  : (user.email ?? "");

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: UserBubble(
                  profilePicUrl: user.profilePicUrl,
                  name: user.name,
                  size: 48,
                  needActiveIndicator: false,
                ),
                title: PrimaryText(
                  user.name,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                subtitle: subtitleText.isNotEmpty
                    ? Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      )
                    : null,
                trailing: OutlinedButton(
                  onPressed: () => _confirmAndUnblock(user),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DefaultColorSheet.green400,
                    side: BorderSide(color: DefaultColorSheet.green400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                  ),
                  child: const Text(
                    "Unblock",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            "Failed to load blocked contacts",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }
}
