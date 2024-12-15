import 'package:map_assignment/src/application/core/base_bloc_event.dart';

class LoginEvent extends BaseBlocEvent {}

class LoginButtonPressed extends LoginEvent {
  final String? accountNumber;
  final String? userName;
  final String? password;

  LoginButtonPressed({
    this.accountNumber,
    this.userName,
    this.password,
  });
}

class EmailAddressChanges extends LoginEvent {
  String email;

  EmailAddressChanges({
    required this.email,
  });
}

class MobileNumberChanged extends LoginEvent {
  String mobileNumber;

  MobileNumberChanged({
    required this.mobileNumber,
  });
}

class PasswordChanged extends LoginEvent {
  String password;

  PasswordChanged({
    required this.password,
  });
}

class InitState extends LoginEvent {}
