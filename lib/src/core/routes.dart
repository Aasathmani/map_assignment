import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_assignment/src/application/core/bloc_provider.dart';
import 'package:map_assignment/src/application/otp/otp_bloc.dart';
import 'package:map_assignment/src/application/web_view/web_view_bloc.dart';
import 'package:map_assignment/src/presentation/login/login_page.dart';
import 'package:map_assignment/src/presentation/otp/otp_page.dart';
import 'package:map_assignment/src/presentation/profile/profile_page.dart';
import 'package:map_assignment/src/presentation/splash/splash_page.dart';
import 'package:map_assignment/src/presentation/web_view/web_view_page.dart';

final Map<String, Widget Function(BuildContext context)> routes = {
  SplashPage.route: (_) => BlocProvider(
        create: (_) => provideSplashBloc(),
        child: const SplashPage(),
      ),
  LoginPage.route: (_) => BlocProvider(
        create: (_) => provideLoginBloc(),
        child: const LoginPage(),
      ),
  ProfilePage.route: (_) => BlocProvider(
        create: (_) => provideProfileBloc(),
        child: const ProfilePage(),
      ),
};

Route<dynamic>? generatedRoutes(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '');
  debugPrint("URI.PATH : ${uri.path}");
  debugPrint("URI.queryParams : ${uri.queryParameters}");
  debugPrint("Settings : ${settings.name}");
  debugPrint("Arguments :  ${settings.arguments ?? "null"}");

  switch (uri.path) {
    case WebViewPage.route:
      if (settings.arguments != null && settings.arguments is WebViewArgument) {
        return _getWebViewRoute(
          settings,
          settings.arguments! as WebViewArgument,
        );
      }
    case OtpPage.route:
      if (settings.arguments != null &&
          settings.arguments is LoginPageArguments) {
        return _getOtpPageRoute(
          settings,
          settings.arguments! as LoginPageArguments,
        );
      }
  }
  return null;
}

MaterialPageRoute _getWebViewRoute(
  RouteSettings settings,
  WebViewArgument argument,
) {
  return MaterialPageRoute(
    builder: (context) => BlocProvider<WebViewBloc>(
      create: (context) => provideWebViewBloc(argument),
      child: const WebViewPage(),
    ),
    settings: settings,
  );
}

MaterialPageRoute _getOtpPageRoute(
  RouteSettings settings,
  LoginPageArguments argument,
) {
  return MaterialPageRoute(
    builder: (context) => BlocProvider<OtpBloc>(
      create: (context) => provideOtpBloc(argument),
      child: const OtpPage(),
    ),
    settings: settings,
  );
}
