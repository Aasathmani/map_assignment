import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_assignment/generated/l10n.dart';
import 'package:map_assignment/src/application/core/base_bloc.dart';
import 'package:map_assignment/src/application/core/process_state.dart';
import 'package:map_assignment/src/application/login/login_event.dart';
import 'package:map_assignment/src/application/login/login_state.dart';
import 'package:map_assignment/src/core/exceptions.dart';
import 'package:map_assignment/src/domain/auth/auth_repository.dart';
import 'package:map_assignment/src/domain/auth/user_repository.dart';
import 'package:map_assignment/src/utils/regex_util.dart';
import 'package:map_assignment/src/utils/string_utils.dart';

class LoginBloc extends BaseBloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  LoginBloc({required this.authRepository, required this.userRepository})
      : super(LoginState()..processState = ProcessState.completed()) {
    on<LoginButtonPressed>((event, emit) async {
      await _onLoginButtonPressed(event: event, emit: emit);
    });

    on<EmailAddressChanges>(
      (event, emit) {
        if (StringUtils.isNotNullAndEmpty(event.email)) {
          emit(
            state.copyWith(
              emailErrorMsg: '',
            ),
          );
        }
        emit(
          state.copyWith(
            email: event.email,
            usernameErrorMsg: '',
            mobileNumber: "",
          ),
        );
      },
    );
    on<MobileNumberChanged>(
      (event, emit) {
        if (StringUtils.isNotNullAndEmpty(event.mobileNumber)) {
          emit(
            state.copyWith(
              usernameErrorMsg: '',
            ),
          );
        }
        emit(
          state.copyWith(
            mobileNumber: event.mobileNumber,
            emailErrorMsg: '',
            email: "",
            password: "",
          ),
        );
      },
    );
    on<PasswordChanged>(
      (event, emit) {
        if (StringUtils.isNotNullAndEmpty(event.password)) {
          emit(
            state.copyWith(
              passwordErrorMsg: '',
            ),
          );
        }
        emit(state.copyWith(password: event.password));
      },
    );
    on<InitState>(
        (event, emit) => emit(state.copyWith(validationSuccess: false)));
  }

  Future<void> _onLoginButtonPressed({
    required LoginButtonPressed event,
    required Emitter<LoginState> emit,
  }) async {
    emit(state.copyWith()..loginFormStatus = ProcessState.busy());

    try {
      if (!_isValid(emit)) {
        emit(state.copyWith()..loginFormStatus = ProcessState.error());
        return;
      }

      emit(
        state.copyWith(
          validationSuccess: true,
          loginFormStatus: ProcessState.completed(),
        ),
      );
    } catch (err) {
      if (err is NoNetworkException) {
        showMessage(S.current.labelNoNetworkAvailable);
      }
    }
  }

  bool _isValid(Emitter<LoginState> emit) {
    bool isValid = true;
    if (StringUtils.isNullOrEmpty(state.mobileNumber) &&
        StringUtils.isNullOrEmpty(state.email)) {
      emit(
        state.copyWith(
          emailErrorMsg: S.current.msgEmailNotValid,
          usernameErrorMsg: S.current.msgMobileNumberNotValid,
        ),
      );
      isValid = false;
    } else if (StringUtils.isNullOrEmpty(state.email) == false &&
        StringUtils.isNullOrEmpty(state.password)) {
      if (RegexUtil.isEmailValid(state.email!) == false) {
        emit(
          state.copyWith(
            emailErrorMsg: S.current.msgEmailNotValid,
          ),
        );
      }
      emit(
        state.copyWith(
          passwordErrorMsg: S.current.msgPasswordValid,
        ),
      );
      isValid = false;
    }

    return isValid;
  }
}
