import 'package:my_app/modal/screens/changePassword/change_password_state.dart';

List<ChangePasswordState> changePasswordInitialState = [
  ChangePasswordState(
    index: 0,
    name: "email",
    matchCondition: r'^[^@]+@[^@]+\.[^@]+',
    status: ChangePasswordStatus.pending,
    buttonMessage: "Send OTP",
  ),
  ChangePasswordState(
    index: 1,
    name: "verify-otp",
    status: ChangePasswordStatus.notStarted,
    buttonMessage: "Verify OTP",
  ),
  ChangePasswordState(
    index: 2,
    name: "changePassword",
    status: ChangePasswordStatus.notStarted,
    matchCondition: r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
    buttonMessage: "Change Password",
  ),
  ChangePasswordState(
    index: 3,
    name: "confirmPassword",
    status: ChangePasswordStatus.notStarted,
  ),
];
