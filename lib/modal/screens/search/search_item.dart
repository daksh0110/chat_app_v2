class SearchItem {
  final String id;
  final String profilePic;
  final String name;
  final String subtitle;

  SearchItem({
    required this.id,
    required this.name,
    this.profilePic = "assets/screens/home/user1.png",
    this.subtitle = "",
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      id: json['_id'],
      name: json['name'],
      subtitle: json["subtitle"],
    );
  }
}
