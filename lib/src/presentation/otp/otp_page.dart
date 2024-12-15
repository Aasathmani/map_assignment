import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_assignment/src/application/otp/otp_bloc.dart';
import 'package:map_assignment/src/application/otp/otp_event.dart';
import 'package:map_assignment/src/application/otp/otp_state.dart';
import 'package:map_assignment/src/core/app_constants.dart';
import 'package:map_assignment/src/presentation/core/app_page.dart';
import 'package:map_assignment/src/presentation/core/base_state.dart';
import 'package:map_assignment/src/presentation/core/theme/colors.dart';
import 'package:map_assignment/src/presentation/core/theme/text_styles.dart';
import 'package:map_assignment/src/presentation/login/login_page.dart';
import 'package:map_assignment/src/presentation/profile/profile_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpPage extends StatefulWidget {
  static const String route = '/pin';

  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends BaseState<OtpPage> {
  OtpBloc? _bloc;

  final TextEditingController enterPinController =
      TextEditingController(text: '');

  final _submitFocus = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<OtpBloc>(context);
      _bloc!.message.listen((value) {
        showMessage(value);
      });
    }
  }

  @override
  void dispose() {
    enterPinController.dispose();
    _submitFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpBloc, OtpState>(listener: (context, state) {
      if (state.correctPinEntered) {
        Navigator.pushNamed(context, ProfilePage.route);
      }
    }, builder: (context, state) {
      return AppPage(
        retryOnTap: () {},
        processStateStream: _bloc!.stream.map((state) => state.processState),
        title: '',
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                _getOtpBoxLayout(context, state),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _getOtpBoxLayout(BuildContext context, OtpState state) {
    String? otpSend;
    if (_bloc!.email != null) {
      otpSend = _bloc!.email;
    } else {
      otpSend = _bloc!.mobileNumber;
    }
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 80,
          ),
          Center(child: Image.asset(AppIcons.kOtpImage)),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              "OTP Verification",
              style: TextStyles.h4(context)?.copyWith(color: AppColors.black),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: Text("Enter the OTP send to $otpSend"),
          ),
          const SizedBox(
            height: 30,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: Units.kContentOffSet,
                  right: Units.kContentOffSet,
                ),
                child: OTPBox(
                  controller: enterPinController,
                  callback: (value) {},
                  isLoading: false,
                  showError: false,
                  callbackForErasingCode: () {},
                  isMaskingEnabled: state.isMaskingEnabled,
                  submitFocus: _submitFocus,
                  onCompleted: () {
                    onOtpSubmitted(state);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, LoginPage.route);
            },
            child: const Center(
              child: Text("Resend OTP"),
            ),
          ),
        ],
      ),
    );
  }

  void onOtpSubmitted(OtpState state) {
    _bloc!.add(PinSubmitted(enterPinController.text));
    if (enterPinController.text.length == 4 &&
        !(state.showConfirmPage || state.isUserHavePin)) {
      enterPinController.text = '';
    }
  }
}

class OTPBox extends StatefulWidget {
  final bool isLoading;

  final bool showError;
  final String? errorMessage;
  final void Function(String) callback;
  final VoidCallback callbackForErasingCode;
  final TextEditingController? controller;
  final bool isMaskingEnabled;
  final FocusNode submitFocus;
  final VoidCallback onCompleted;

  const OTPBox({
    super.key,
    required this.isLoading,
    required this.callbackForErasingCode,
    required this.showError,
    required this.callback,
    this.errorMessage,
    this.controller,
    required this.isMaskingEnabled,
    required this.submitFocus,
    required this.onCompleted,
  });

  @override
  _OTPBoxState createState() => _OTPBoxState();
}

class _OTPBoxState extends BaseState<OTPBox> {
  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onFocusChange: (value) {},
      child: PinCodeTextField(
        autoFocus: true,
        enablePinAutofill: false,
        appContext: context,
        length: 4,
        obscureText: widget.isMaskingEnabled,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        pinTheme: PinTheme(
          borderWidth: 1,
          borderRadius: BorderRadius.circular(6),
          shape: PinCodeFieldShape.box,
          fieldHeight: 50,
          fieldWidth: 50,
          inactiveFillColor: AppColors.grey.withOpacity(0.2),
          inactiveColor: AppColors.grey.withOpacity(0.2),
          selectedColor: AppColors.grey.withOpacity(0.2),
          selectedFillColor: AppColors.grey.withOpacity(0.2),
          activeFillColor: Colors.grey,
          activeColor: widget.showError
              ? Colors.red
              : widget.isLoading
                  ? Colors.green
                  : Colors.blue,
        ),
        enableActiveFill: true,
        controller: widget.controller,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        onSubmitted: (_) {
          focusChange(context, null, widget.submitFocus);
        },
        onCompleted: (v) {
          focusChange(context, null, widget.submitFocus);
          widget.onCompleted.call();
        },
        onChanged: (value) {
          widget.callback(value);
        },
      ),
    );
  }
}

class EnterPinArguments {
  bool isForResuming;

  EnterPinArguments({required this.isForResuming});
}
