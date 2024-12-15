import 'package:map_assignment/src/application/core/base_bloc_event.dart';

class OtpEvent extends BaseBlocEvent {}

class Initialize extends OtpEvent {}

class CheckPinStatus extends OtpEvent {
  CheckPinStatus();
}

class FourDigitValidation extends OtpEvent {
  FourDigitValidation();
}

class ShowPinTapped extends OtpEvent {
  ShowPinTapped();
}

class PinSubmitted extends OtpEvent {
  final String pin;
  PinSubmitted(this.pin);
}
