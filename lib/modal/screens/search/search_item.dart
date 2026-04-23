class SearchItem {
  final String id;
  final String profilePic;
  final String name;
  final String subtitle;
  final String? bio;
  final String? profilePicUrl;
  final String? email;

  SearchItem({
    required this.id,
    required this.name,
    this.profilePic = "assets/screens/home/user1.png",
    this.subtitle = "",
    this.bio,
    this.profilePicUrl,
    this.email = "",
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      id: json['_id'],
      name: json['name'],
      subtitle: json["subtitle"] ?? json["email"],
      bio: json['bio'],
      profilePicUrl: json['profile_picture'],
      email: json["email"],
    );
  }
}
