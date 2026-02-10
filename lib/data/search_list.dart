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
        profilePic: "assets/screens/home/user1.png",
        subtitle: "Be your own hero 💪",
      ),
      SearchItem(
        id: "2",
        name: "Bristy Haque",
        profilePic: "assets/screens/home/user2.png",
        subtitle: "Keep working ✍️",
      ),
      SearchItem(
        id: "3",
        name: "John Borino",
        profilePic: "assets/screens/home/user3.png",
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
        profilePic: "assets/screens/home/user4.png",
        subtitle: "4 participants",
      ),
      SearchItem(
        id: "5",
        name: "Team Align",
        profilePic: "assets/screens/home/user5.png",
        subtitle: "8 participants",
      ),
    ],
  ),
];
