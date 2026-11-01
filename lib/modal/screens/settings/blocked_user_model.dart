class BlockedUserModel {
  final String userId;
  final String name;
  final String? email;
  final String? bio;
  final String? profilePicUrl;
  final DateTime blockedAt;

  const BlockedUserModel({
    required this.userId,
    required this.name,
    this.email,
    this.bio,
    this.profilePicUrl,
    required this.blockedAt,
  });
}

