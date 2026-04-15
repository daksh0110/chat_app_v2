enum ChangePasswordStatus { notStarted, pending, success }

class ChangePasswordState {
  final int index;
  final String name;
  final String matchCondition;
  final ChangePasswordStatus status;
  final String buttonMessage;

  ChangePasswordState({
    required this.index,
    this.status = ChangePasswordStatus.pending,
    required this.name,
    this.matchCondition = "",
    this.buttonMessage = "Submit",
  });

  ChangePasswordState copyWith({
    ChangePasswordStatus? status,
    int? index,
    String? name,
    String? matchCondition,
    String? buttonMessage,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      index: index ?? this.index,
      name: name ?? this.name,
      matchCondition: matchCondition ?? this.matchCondition,
      buttonMessage: buttonMessage ?? this.buttonMessage,
    );
  }
}
