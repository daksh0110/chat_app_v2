import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/util/debouncer.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/screens/search/search_item_group.dart';
import 'package:my_app/providers/search_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/search/search_group.dart';

class Search extends ConsumerStatefulWidget {
  const Search({super.key});

  @override
  ConsumerState<Search> createState() {
    return _SearchState();
  }
}

class _SearchState extends ConsumerState<Search> {
  final List<SearchItemGroup> data = [];
  final ApiClient apiClient = ApiClient();
  final TextEditingController _searchInputController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  void onSearching(String text) {
    _debouncer.run(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = ref
        .watch(searchProvider.notifier)
        .getSearchResults(_searchInputController.text.trim());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,

        title: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: DefaultColorSheet.disbaledButton,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.search, size: 20),

              const SizedBox(width: 8),

              Expanded(
                child: TextField(
                  controller: _searchInputController,
                  onChanged: (value) => onSearching(value),
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                onPressed: () {
                  _searchInputController.clear();

                  setState(() {
                    data.clear();
                  });
                },
                icon: const Icon(LucideIcons.x, size: 20),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsetsDirectional.only(top: 20),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<SearchItem>>(
                stream: recentSearches,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint("Search.StreamBuilder error: ${snapshot.error}");
                    return Center(
                      child: PrimaryText(
                        "Search failed: ${snapshot.error}",
                        color: DefaultColorSheet.grey500,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: PrimaryText(
                        "No recent searches",
                        color: DefaultColorSheet.grey500,
                      ),
                    );
                  }

                  final recentSearches = snapshot.data!;
                  final usersList = SearchItemGroup(
                    id: 'users',
                    name: 'Users',
                    items: recentSearches
                        .where((item) => item.actorType == 'USER')
                        .toList(),
                  );
                  final groupsList = SearchItemGroup(
                    id: 'groups',
                    name: 'Groups',
                    items: recentSearches
                        .where((item) => item.actorType == 'GROUP')
                        .toList(),
                  );
                  final otherList = SearchItemGroup(
                    id: 'other',
                    name: 'Other',
                    items: recentSearches
                        .where((item) => item.actorType == 'OTHER')
                        .toList(),
                  );

                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      if (usersList.items.isNotEmpty) ...[
                        SearchGroup(list: usersList),
                      ],
                      if (groupsList.items.isNotEmpty) ...[
                        SearchGroup(list: groupsList),
                      ],
                      if (otherList.items.isNotEmpty) ...[
                        SearchGroup(list: otherList),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
