import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_assignment/generated/l10n.dart';
import 'package:map_assignment/src/application/login/login_bloc.dart';
import 'package:map_assignment/src/application/login/login_event.dart';
import 'package:map_assignment/src/application/login/login_state.dart';
import 'package:map_assignment/src/core/app_constants.dart';
import 'package:map_assignment/src/presentation/core/app_page.dart';
import 'package:map_assignment/src/presentation/core/base_state.dart';
import 'package:map_assignment/src/presentation/core/theme/colors.dart';
import 'package:map_assignment/src/presentation/core/theme/text_styles.dart';
import 'package:map_assignment/src/presentation/otp/otp_page.dart';
import 'package:map_assignment/src/presentation/profile/profile_page.dart';
import 'package:map_assignment/src/presentation/widgets/RequiredTextWidget.dart';
import 'package:map_assignment/src/presentation/widgets/app_button.dart';
import 'package:map_assignment/src/presentation/widgets/bordered_text_field.dart';

class LoginPage extends StatefulWidget {
  static String route = '/loginPage';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends BaseState<LoginPage> {
  LoginBloc? _bloc;
  double screenHeight = 0;
  late ColorScheme _theme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<LoginBloc>(context);
      _bloc!.message.listen((value) => showMessage(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.sizeOf(context).height;
    _theme = Theme.of(context).colorScheme;
    return BlocListener<LoginBloc, LoginState>(
      listener: (BuildContext context, LoginState state) {
        if (state.validationSuccess == true) {
          if (state.mobileNumber!.isNotEmpty) {
            _bloc!.add(InitState());
            Navigator.pushNamed(
              context,
              OtpPage.route,
              arguments: LoginPageArguments(
                email: state.email,
                mobileNumber: state.mobileNumber,
                password: state.password,
              ),
            );
          } else {
            _bloc!.add(InitState());
            Navigator.pushNamed(
              context,
              ProfilePage.route,
            );
          }
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        bloc: _bloc,
        builder: (context, state) {
          return AppPage(
            retryOnTap: () {},
            processStateStream:
                _bloc!.stream.map((state) => state.processState),
            title: '',
            child: _body(context, state),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, LoginState state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Expanded(
          child: Positioned(
            child: Image.asset(
              AppIcons.kLoginBg,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Units.kXLPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _loginText(context),
                  const SizedBox(height: 50.0),
                  _mobileNumberText(context),
                  const SizedBox(height: 8.0),
                  _mobileNumberTextField(context),
                  const SizedBox(height: 20.0),
                  _orDivider(context),
                  const SizedBox(height: 20.0),
                  _getEmailText(context),
                  const SizedBox(height: 8.0),
                  _emailTextField(context),
                  const SizedBox(height: 20.0),
                  _passwordText(context),
                  const SizedBox(height: 8.0),
                  _passwordTextField(context),
                  const SizedBox(
                    height: 70,
                  ),
                  loginButton(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginText(BuildContext context) {
    return Align(
      child: Text(
        "Login page",
        style: TextStyles.h5(context),
      ),
    );
  }

  Widget _mobileNumberText(BuildContext context) {
    return RequiredTextWidget(
      text: 'Mobile Number',
      textStyle: TextStyles.title2Bold(context)?.copyWith(
        color: _theme.secondary,
      ),
      isRequired: false,
    );
  }

  Widget _mobileNumberTextField(BuildContext context) {
    return BorderedTextField(
      key: const Key("Mobile number"),
      backgroundColor: _theme.onPrimary,
      maxLines: 1,
      onTextChanged: (text) {
        _bloc!.add(MobileNumberChanged(mobileNumber: text.trim()));
      },
      textInputType: TextInputType.number,
      textStream: _bloc!.stream.map((state) => state.mobileNumber),
      errorStream: _bloc!.stream.map((state) => state.usernameErrorMsg),
    );
  }

  Widget _orDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            color: AppColors.black,
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Units.kSPadding, vertical: Units.kSPadding),
            child: Text(
              "Or",
              style: TextStyles.body1Bold(context),
            )),
        Expanded(
          child: Container(height: 2, color: AppColors.black),
        ),
      ],
    );
  }

  Widget _getEmailText(BuildContext context) {
    return RequiredTextWidget(
      text: 'Email address ',
      textStyle: TextStyles.title2Bold(context)?.copyWith(
        color: _theme.secondary,
      ),
      isRequired: false,
    );
  }

  Widget _emailTextField(BuildContext context) {
    return BorderedTextField(
      key: const Key("E-mail"),
      backgroundColor: _theme.onPrimary,
      labelText: 'E-mail',
      maxLines: 1,
      onTextChanged: (text) {
        _bloc!.add(EmailAddressChanges(email: text.trim()));
      },
      textStream: _bloc!.stream.map((state) => state.email),
      errorStream: _bloc!.stream.map((state) => state.emailErrorMsg),
    );
  }

  Widget _passwordText(BuildContext context) {
    return RequiredTextWidget(
      text: 'Password',
      textStyle: TextStyles.title2Bold(context)?.copyWith(
        color: _theme.secondary,
      ),
      isRequired: false,
    );
  }

  Widget _passwordTextField(BuildContext context) {
    return BorderedTextField(
      key: const Key("Password"),
      backgroundColor: _theme.onPrimary,
      obscureText: true,
      maxLines: 1,
      onTextChanged: (text) {
        _bloc!.add(PasswordChanged(password: text.trim()));
      },
      textStream: _bloc!.stream.map((state) => state.password),
      errorStream: _bloc!.stream.map((state) => state.passwordErrorMsg),
    );
  }

  Widget loginButton(BuildContext context) {
    return AppButton(
      height: 50,
      onTap: () {
        _bloc!.add(LoginButtonPressed());
      },
      label: S.current.labelLogin.toUpperCase(),
      color: AppColors.green,
    );
  }
}

class LoginPageArguments {
  String? email;
  String? mobileNumber;
  String? password;
  LoginPageArguments({
    this.mobileNumber,
    this.email,
    this.password,
  });
}
