import 'package:map_assignment/src/application/core/base_bloc_state.dart';

class OtpState extends BaseBlocState {
  OtpState({
    this.isUserHavePin = false,
    this.correctPinEntered = false,
    this.showConfirmPage = false,
    this.pinEntered = '',
    this.confirmPinEntered = '',
    this.isMaskingEnabled = true,
  });

  bool isUserHavePin;
  bool correctPinEntered;

  bool showConfirmPage;
  String? pinEntered;
  String? confirmPinEntered;
  bool isMaskingEnabled;

  @override
  OtpState copyWith({
    bool? isUserHavePin,
    bool? correctPinEntered,
    bool? showConfirmPage,
    String? pinEntered,
    String? confirmPinEntered,
    bool? showFourDigitValidation,
    bool? pinMissMatch,
    bool? isMaskingEnabled,
  }) {
    return OtpState(
      correctPinEntered: correctPinEntered ?? this.correctPinEntered,
      isUserHavePin: isUserHavePin ?? this.isUserHavePin,
      showConfirmPage: showConfirmPage ?? this.showConfirmPage,
      pinEntered: pinEntered ?? this.pinEntered,
      confirmPinEntered: confirmPinEntered ?? this.confirmPinEntered,
      isMaskingEnabled: isMaskingEnabled ?? this.isMaskingEnabled,
    )..processState = processState;
  }
}
