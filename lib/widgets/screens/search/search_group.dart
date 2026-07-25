import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/modal/api_response.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/screens/search/search_item_group.dart';
import 'package:my_app/providers/tables/recent_search_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/search/search_group_item.dart';

class SearchGroup extends ConsumerWidget {
  const SearchGroup({super.key, required this.list});
  final SearchItemGroup list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = ApiClient();

    if (list.items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        PrimaryText(list.name, fontSize: 16, fontWeight: FontWeight.w500),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          itemBuilder: (context, index) {
            final item = list.items[index];
            final media = item.media;
            final profilePicUrl = item.profilePicUrl;

            return FutureBuilder<ApiResponse<String>>(
              future:
                  (profilePicUrl == null || profilePicUrl.isEmpty) &&
                      media?.key != null
                  ? UploadService(apiClient).getDownloadUrl(media!.key)
                  : null,
              builder: (context, snapshot) {
                final imageUrl = snapshot.data?.data;
                return SearchGroupItem(
                  item: SearchItem(
                    id: item.id,
                    name: item.name,
                    bio: item.bio,
                    email: item.email,
                    profilePicUrl: imageUrl ?? item.profilePicUrl,
                    media: item.media,
                  ),
                  onTap: () {
                    ref
                        .read(recentSearchProvider.notifier)
                        .addRecentSearch(
                          SearchItem(
                            id: item.id,
                            name: item.name,
                            bio: item.bio,
                            email: item.email,
                            media: item.media,
                            actorType: item.actorType,
                          ),
                        );

                    Navigator.pushNamed(
                      context,
                      AppRoutes.message,
                      arguments: MessageScreenArguments(
                        receiverId: item.id,
                        name: item.name,
                        profilePicUrl: imageUrl ?? item.profilePicUrl,
                      ),
                    );
                  },
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
