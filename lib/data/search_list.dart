import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/screens/search/search_item_group.dart';

final List<SearchItemGroup> searchList = [
  SearchItemGroup(
    id: "people",
    name: "People",
    items: [
      SearchItem(
        id: "1",
        name: "Adil Adnan",
        profilePicUrl: null,
        subtitle: "Be your own hero 💪",
      ),
      SearchItem(
        id: "2",
        name: "Bristy Haque",
        profilePicUrl: null,
        subtitle: "Keep working ✍️",
      ),
      SearchItem(
        id: "3",
        name: "John Borino",
        profilePicUrl: null,
        subtitle: "Make yourself proud 😍",
      ),
    ],
  ),

  SearchItemGroup(
    id: "groups",
    name: "Group Chat",
    items: [
      SearchItem(
        id: "4",
        name: "Team Align-Practise",
        profilePicUrl: null,
        subtitle: "4 participants",
      ),
      SearchItem(
        id: "5",
        name: "Team Align",
        profilePicUrl: null,
        subtitle: "8 participants",
      ),
    ],

  ),
];
