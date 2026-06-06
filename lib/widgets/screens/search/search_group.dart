import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/modal/screens/search/search_item_group.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/search/search_group_item.dart';
import 'package:my_app/providers/recent_searches_provider.dart';

class SearchGroup extends ConsumerWidget {
  const SearchGroup({super.key, required this.list});
  final SearchItemGroup list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        PrimaryText(list.name, fontSize: 16, fontWeight: FontWeight.w500),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return SearchGroupItem(
              item: list.items[index],
              onTap: () {
                final item = list.items[index];
                ref.read(recentSearchesProvider).upsertRecentSearch(
                  userId: item.id,
                  name: item.name,
                  email: item.email ?? "",
                  profilePicUrl: item.profilePicUrl,
                );

                Navigator.pushNamed(
                  context,
                  AppRoutes.message,
                  arguments: MessageScreenArguments(
                    receiverId: item.id,
                    name: item.name,
                    profilePicUrl: item.profilePicUrl,
                  ),
                );
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 30),
          itemCount: list.items.length,
        ),
      ],
    );
  }
}
