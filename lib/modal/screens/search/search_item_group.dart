import 'package:my_app/modal/screens/search/search_item.dart';

class SearchItemGroup {
  final String id;
  final String name;
  final List<SearchItem> items;

  SearchItemGroup({
    required this.id,
    required this.name,
    List<SearchItem>? items,
  }) : items = items ?? [];
}
