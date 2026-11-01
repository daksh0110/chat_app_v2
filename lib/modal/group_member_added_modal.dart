import 'package:my_app/modal/group_info_modal.dart';
import 'package:my_app/modal/screens/createGroup/create_group_response.dart';

class GroupMemberAddedModal {
  final String chatId;
  final String userId;
  final String role;
  final String actorId;
  final String actorName;
  final String memberName;
  final GroupInfoModal? group;
  final List<Participant> participants;
  final int? sequence;

  GroupMemberAddedModal({
    required this.chatId,
    required this.userId,
    this.role = 'MEMBER',
    this.actorId = '',
    this.actorName = '',
    this.memberName = '',
    this.group,
    this.participants = const [],
    this.sequence,
  });

  factory GroupMemberAddedModal.fromJson(Map<String, dynamic> json) {
    return GroupMemberAddedModal(
      chatId: json['chat_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      role: json['role'] as String? ?? 'MEMBER',
      actorId: json['actor_id'] as String? ?? '',
      actorName: json['actor_name'] as String? ?? '',
      memberName: json['member_name'] as String? ?? '',
      group: json['group'] != null && json['group'] is Map
          ? GroupInfoModal.fromJson(Map<String, dynamic>.from(json['group']))
          : null,
      participants: (json['participants'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Participant.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      sequence: json['sequence'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'user_id': userId,
        'role': role,
        'actor_id': actorId,
        'actor_name': actorName,
        'member_name': memberName,
        'group': group?.toJson(),
        'sequence': sequence,
      };
}

