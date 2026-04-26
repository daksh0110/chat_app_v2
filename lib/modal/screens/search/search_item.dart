class SearchItem {
  final String id;
  final String name;
  final String subtitle;
  final String? bio;
  final String? profilePicUrl;
  final String? email;

  SearchItem({
    required this.id,
    required this.name,
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

