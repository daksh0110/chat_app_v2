class SearchItem {
  final String id;
  final String profilePic;
  final String name;
  final String subtitle;
  final String? bio;
  final String? profilePicUrl;

  SearchItem({
    required this.id,
    required this.name,
    this.profilePic = "assets/screens/home/user1.png",
    this.subtitle = "",
    this.bio,
    this.profilePicUrl,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      id: json['_id'],
      name: json['name'],
      subtitle: json["subtitle"] ?? json["email"],
      bio: json['bio'],
      profilePicUrl: json['profile_pic'],
    );
  }
}
