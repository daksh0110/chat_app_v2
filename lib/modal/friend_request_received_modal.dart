class FriendRequestModal {
  final String requesterId;

  FriendRequestModal({required this.requesterId});

  factory FriendRequestModal.fromJson(Map<String, dynamic> json) {
    return FriendRequestModal(requesterId: json['requester_id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'requester_id': requesterId};
  }

  @override
  String toString() {
    return 'FriendRequestModal(requester_id: $requesterId)';
  }
}
