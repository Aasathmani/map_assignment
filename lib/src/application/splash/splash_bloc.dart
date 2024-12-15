import 'package:map_assignment/src/application/core/base_bloc.dart';
import 'package:map_assignment/src/application/splash/splash_event.dart';
import 'package:map_assignment/src/application/splash/splash_state.dart';
import 'package:map_assignment/src/domain/auth/auth_repository.dart';
import 'package:map_assignment/src/domain/auth/user_repository.dart';

class SplashBloc extends BaseBloc<SplashEvent, SplashState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  SplashBloc({required this.authRepository, required this.userRepository})
      : super(SplashState()) {
    on<RedirectPage>(
      (event, emit) async {
        final authToken = await authRepository.getActiveToken();
        final user = await userRepository.getActiveUser();
        await Future.delayed(const Duration(milliseconds: 2000), () {});
        if (user != null && authToken != null) {
          emit(state.copyWith(redirectToOtp: true));
        } else {
          await authRepository.signOut();
          emit(state.copyWith(redirectToLogin: true));
        }
      },
    );
  }
}
