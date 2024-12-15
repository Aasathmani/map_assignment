import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_assignment/generated/l10n.dart';
import 'package:map_assignment/src/application/core/base_bloc.dart';
import 'package:map_assignment/src/application/otp/otp_event.dart';
import 'package:map_assignment/src/application/otp/otp_state.dart';
import 'package:map_assignment/src/domain/auth/auth_repository.dart';
import 'package:map_assignment/src/utils/network_validator.dart';

class OtpBloc extends BaseBloc<OtpEvent, OtpState> {
  final AuthRepository authRepository;
  final NetworkValidator networkValidator;
  final String? email;
  final String? mobileNumber;

  OtpBloc({
    required this.authRepository,
    required this.networkValidator,
    this.email,
    this.mobileNumber,
  }) : super(OtpState()) {
    on<FourDigitValidation>(
      (event, emit) {
        showValidationMessage("enter pin"); //S.current.labelEnterPinNumber);
      },
    );

    on<ShowPinTapped>(
      (event, emit) {
        showPinTapped(emit);
      },
    );
    on<PinSubmitted>(
      (event, emit) async {
        await pinSubmitted(event, emit);
      },
    );
  }

  void showPinTapped(Emitter<OtpState> emit) {
    emit(state.copyWith(isMaskingEnabled: !state.isMaskingEnabled));
  }

  void showValidationMessage(String str) {
    showMessage(str);
  }

  Future<void> pinSubmitted(
    PinSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    if (event.pin.length != 4) {
      showValidationMessage(S.current.labelEnterPinNumber);
    } else {
      await pinEnteredFunction(event.pin, emit);
    }
  }

  Future<void> pinEnteredFunction(
    String pin,
    Emitter<OtpState> emit,
  ) async {
    if (pin == "1234") {
      emit(state.copyWith(correctPinEntered: true));
    } else {
      showMessage("Please enter correct four digit pin");
    }
  }
}
