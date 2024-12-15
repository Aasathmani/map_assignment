import 'package:map_assignment/src/application/core/base_bloc_state.dart';
import 'package:map_assignment/src/application/core/process_state.dart';

class LoginState extends BaseBlocState {
  String? email;
  String? mobileNumber;
  String? password;
  String? emailErrorMsg;
  String? passwordErrorMsg;
  String? usernameErrorMsg;
  ProcessState? loginFormStatus;
  bool? validationSuccess;

  LoginState({
    this.email,
    this.mobileNumber,
    this.password,
    this.loginFormStatus,
    this.emailErrorMsg = '',
    this.passwordErrorMsg = '',
    this.usernameErrorMsg = '',
    this.validationSuccess = false,
  });

  @override
  LoginState copyWith({
    String? email,
    String? mobileNumber,
    String? password,
    String? emailErrorMsg,
    String? passwordErrorMsg,
    String? usernameErrorMsg,
    ProcessState? loginFormStatus,
    bool? validationSuccess,
  }) {
    return LoginState(
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      password: password ?? this.password,
      emailErrorMsg: emailErrorMsg ?? this.emailErrorMsg,
      usernameErrorMsg: usernameErrorMsg ?? this.usernameErrorMsg,
      passwordErrorMsg: passwordErrorMsg ?? this.passwordErrorMsg,
      loginFormStatus: loginFormStatus ?? this.loginFormStatus,
      validationSuccess: validationSuccess ?? this.validationSuccess,
    )..processState = processState;
  }
}
