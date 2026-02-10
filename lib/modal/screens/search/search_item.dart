class SearchItem {
  final String id;
  final String profilePic;
  final String name;
  final String subtitle;

  SearchItem({
    required this.id,
    required this.name,
    this.profilePic = "",
    this.subtitle = "",
  });
}
