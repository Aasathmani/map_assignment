import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:map_assignment/src/core/app.dart';
import 'package:map_assignment/src/core/exceptions.dart';
import 'package:map_assignment/src/domain/auth/auth_service.dart';
import 'package:map_assignment/src/domain/auth/user_repository.dart';
import 'package:map_assignment/src/domain/core/config_repository.dart';
import 'package:map_assignment/src/domain/core/log_services.dart';
import 'package:map_assignment/src/domain/database/auth_settings_dao.dart';
import 'package:map_assignment/src/domain/database/auth_token_dao.dart';
import 'package:map_assignment/src/domain/database/core/app_database.dart';
import 'package:map_assignment/src/presentation/widgets/loader_widget.dart';
import 'package:map_assignment/src/utils/secure_storage_util.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:synchronized/synchronized.dart';

class AuthRepository {
  static AuthRepository? instance;

  final AuthService authServices;
  final AuthTokenDao authTokenDao;
  final AuthSettingsDao authSettingsDao;
  final UserRepository userRepository;
  final ConfigRepository configRepository;
  final FlutterSecureStorage storage;
  final AppDatabase appDatabase;
  final Logger logger;

  static Lock? _lock;
  static const String _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  AuthRepository({
    required this.authServices,
    required this.authTokenDao,
    required this.authSettingsDao,
    required this.appDatabase,
    required this.userRepository,
    required this.configRepository,
    required this.storage,
    required this.logger,
  }) {
    _lock ??= Lock();
  }

  static String _createCodeVerifier() {
    return List.generate(
      128,
      (i) => _charset[Random.secure().nextInt(_charset.length)],
    ).join();
  }

  Future<User?> signIn() async {
    await authTokenDao.deleteTokens();

    if (!configRepository.isInitialFetchCompleted()) {
      await configRepository.syncConfig();
    }

    String? codeVerifier;
    if (await storage.containsKey(key: SecureStorageKey.codeVerifier)) {
      codeVerifier = await storage.read(key: SecureStorageKey.codeVerifier);
    }
    codeVerifier ??= _createCodeVerifier();
    _saveCodeVerifier(codeVerifier);

    final credentials = !kIsWeb && Platform.isWindows
        ? await authServices.signInWindows(codeVerifier: codeVerifier)
        : await authServices.signIn(codeVerifier: codeVerifier);
    if (credentials != null) {
      logger.log(LogEvents.loggedIn, null);
      _saveCredentials(credentials);
      return _updateUser(_generateAuthTokenFromCredential(credentials));
    } else {
      logger.log(LogEvents.logInFailed, null);
      return null;
    }
  }

  Future<void> _refreshAccessToken() async {
    final savedCredentials = oauth2.Credentials.fromJson(
      await storage.read(key: SecureStorageKey.oAuthCredentials) ?? '',
    );

    final credentials = await authServices.refreshAccessToken(savedCredentials);
    _saveCredentials(credentials);
    await _updateUser(_generateAuthTokenFromCredential(credentials));
  }

  AuthToken _generateAuthTokenFromCredential(oauth2.Credentials credential) {
    final authToken = AuthToken(
      accessToken: credential.accessToken,
      idToken: credential.idToken ?? '',
      refreshToken: credential.refreshToken ?? '',
    );
    return authToken;
  }

  Future<User> _updateUser(AuthToken authToken) async {
    try {
      final user = await userRepository.getUser(authToken);
      logger.log(LogEvents.userFetchFromIDS, null);
      await userRepository.deleteUsers();
      await authTokenDao.deleteTokens();
      await authTokenDao.saveAuthToken(authToken);
      await userRepository.saveUser(user);
      logger.log(LogEvents.logInDBUpdate, null);
      return user;
    } catch (e) {
      debugPrint(e.toString());
      logger.log(LogEvents.logInDBUpdateFailed, null);
      rethrow;
    }
  }

  Future<AuthToken?> getActiveToken() {
    return authTokenDao.getActiveSessionToken();
  }

  Future<bool> isSessionActive() async {
    final token = await getActiveToken();
    final user = await userRepository.getActiveUser();
    return token != null && user != null;
  }

  Future<bool> signOut() async {
    final token = await getActiveToken();
    final String? codeVerifier =
        await storage.read(key: SecureStorageKey.codeVerifier);

    if (token != null && codeVerifier != null) {
      try {
        await authServices.signOut(token, codeVerifier);
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
    }

    Future.value([
      await appDatabase.clearUserRelatedTables(),
      await storage.deleteAll(),
      await authSettingsDao.clear(),
      await _saveCredentials(null),
    ]);

    /*   bool isNewRouteSameAsCurrent = false;
     Navigator.popUntil(navigatorKey.currentContext!, (route) {
      if (route.settings.name == LoginPage.route) {
        isNewRouteSameAsCurrent = true;
        return true;
      }
      return false;
    });*/

/*    if (!isNewRouteSameAsCurrent) {
      await Navigator.pushNamed(navigatorKey.currentContext!, LoginPage.route);
    }*/
    return true;
  }

  Future<void> processAuthError() async {
    await _lock!.synchronized(() async {
      final lastRefresh = await authSettingsDao.getLastTokenRefresh();
      if (lastRefresh == null ||
          DateTime.now().toUtc().difference(lastRefresh).inMinutes >= 4) {
        await initRefreshAccessToken();
      }
    });
  }

  Future<void> initRefreshAccessToken() async {
    final token = await getActiveToken();
    if (token?.refreshToken != null) {
      try {
        await _refreshAccessToken();
        // await authSettingsDao.saveLastTokenRefresh(DateTime.now().toUtc());
      } catch (err) {
        if ((err is PlatformException &&
                (err.code == "token_failed" ||
                    err.code == "401" ||
                    err.code == "400")) ||
            (err is oauth2.AuthorizationException &&
                err.error == "invalid_grant")) {
          await _logoutAndNavigateToLogin();
        }
        throw CustomException(
          "FAILED TO REFRESH TOKEN",
          message: err.toString(),
        );
      }
    } else {
      await _logoutAndNavigateToLogin();
    }
  }

  Future _logoutAndNavigateToLogin() async {
    late BuildContext loaderContext;
    showDialog(
      context: navigatorKey.currentState!.overlay!.context,
      barrierDismissible: false,
      builder: (context) {
        loaderContext = context;
        return WillPopScope(
          onWillPop: () async => false,
          child: const LoaderWidget(),
        );
      },
    );
    await signOut().then((value) {
      if (loaderContext.mounted) Navigator.pop(loaderContext);
    });
  }

  Future<void> _saveCodeVerifier(String codeVerifier) async {
    await storage.write(
      key: SecureStorageKey.codeVerifier,
      value: codeVerifier,
    );
  }

  Future<void> _saveCredentials(oauth2.Credentials? credentials) async {
    await storage.write(
      key: SecureStorageKey.oAuthCredentials,
      value: credentials?.toJson(),
    );
  }
}
