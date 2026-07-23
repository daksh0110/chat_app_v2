import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/providers/tables/recent_search_provider.dart';
import 'package:my_app/providers/token_provider.dart';

final searchProvider = NotifierProvider<SearchProvider, void>(
  SearchProvider.new,
);

class SearchProvider extends Notifier<void> {
  @override
  build() {}

  Stream<List<SearchItem>> getSearchResults(String query) {
    return ref.read(recentSearchProvider.notifier).getRecentSearches().asyncMap(
      (items) async {
        print("Recent search stream emitted ${items.length}");
        if (query.isEmpty) {
          return items.take(10).toList();
        }

        final searchQuery = query.toLowerCase();

        final recentResults = items.where((item) {
          final name = item.name.toLowerCase();
          final email = item.email?.toLowerCase() ?? '';

          return name.contains(searchQuery) || email.contains(searchQuery);
        }).toList();

        if (recentResults.length >= 10) {
          return recentResults.take(10).toList();
        }
        final remainingSlots = 10 - recentResults.length;
        final token = ref.read(tokenProvider).value;

        final recentSearchApi = await UserApiService(ApiClient()).getUsers(
          page: 1,
          search: query,
          token: token ?? "",
          limit: remainingSlots,
        );
        final data = recentSearchApi.data ?? [];
        final List<SearchItem> apiResults = data.map((user) {
          return SearchItem(
            id: user.id,
            name: user.name,
            email: user.email,
            bio: user.bio,
            media: user.media,
            actorType: 'USER',
          );
        }).toList();

        final combinedResults = [
          ...recentResults,
          ...apiResults.where(
            (item) => !recentResults.any((r) => r.id == item.id),
          ),
        ];

        return combinedResults.take(10).toList();
      },
    );
  }
}
