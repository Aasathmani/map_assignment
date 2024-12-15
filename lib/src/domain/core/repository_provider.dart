import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:map_assignment/src/domain/auth/auth_repository.dart';
import 'package:map_assignment/src/domain/auth/auth_service.dart';
import 'package:map_assignment/src/domain/auth/user_repository.dart';
import 'package:map_assignment/src/domain/auth/user_service.dart';
import 'package:map_assignment/src/domain/core/config_repository.dart';
import 'package:map_assignment/src/domain/core/log_services.dart';
import 'package:map_assignment/src/domain/core/remote_config/remote_config_repository.dart';
import 'package:map_assignment/src/domain/core/remote_config/remote_config_service.dart';
import 'package:map_assignment/src/domain/database/auth_settings_dao.dart';
import 'package:map_assignment/src/domain/database/core/app_database.dart';
import 'package:map_assignment/src/domain/database/remote_config_dao.dart';
import 'package:map_assignment/src/domain/fcm/device_token_repository.dart';
import 'package:map_assignment/src/domain/fcm/device_token_service.dart';
import 'package:map_assignment/src/utils/biometric_local_auth_utils.dart';
import 'package:map_assignment/src/utils/file_downloader.dart';
import 'package:map_assignment/src/utils/network_validator.dart';

ConfigRepository provideConfigRepository() {
  return ConfigRepository.instance();
}

RemoteConfigRepository provideRemoteConfigRepository() {
  return RemoteConfigRepository.instance ??= RemoteConfigRepository(
    dao: RemoteConfigDao(),
    service: RemoteConfigService(
      configRepository: provideConfigRepository(),
      assetBundle: rootBundle,
    ),
  );
}

FlutterSecureStorage provideFlutterSecureStorage() {
  return const FlutterSecureStorage();
}

Logger provideLogger() {
  return Logger();
}

NetworkValidator provideNetworkValidator() {
  return NetworkValidator.instance ??= NetworkValidator(
    connectivity: Connectivity(),
  );
}

AppDatabase provideAppDatabase() {
  return AppDatabase.instance();
}

UserService provideUserService() {
  return UserService(
    configRepository: provideConfigRepository(),
  );
}

AuthRepository provideAuthRepository() {
  return AuthRepository.instance ??= AuthRepository(
    authServices: AuthService(),
    authTokenDao: provideAppDatabase().authTokenDao,
    appDatabase: provideAppDatabase(),
    authSettingsDao: AuthSettingsDao(),
    userRepository: provideUserRepository(),
    storage: provideFlutterSecureStorage(),
    logger: provideLogger(),
    configRepository: provideConfigRepository(),
  );
}

UserRepository provideUserRepository() {
  return UserRepository.instance ??= UserRepository(
    userDao: provideAppDatabase().userDao,
    networkProvider: provideUserService(),
    userMapper: UserMapper(),
  );
}

DeviceTokenRepository provideDeviceTokenRepository() {
  return DeviceTokenRepository(
    messagingService: provideFireBaseMessaging(),
    tokenServices: provideDeviceTokenServices(),
    flutterSecureStorage: provideFlutterSecureStorage(),
  );
}

FirebaseMessaging provideFireBaseMessaging() {
  return FirebaseMessaging.instance;
}

DeviceTokenService provideDeviceTokenServices() {
  return DeviceTokenService();
}

FileDownloader provideFileDownloader() {
  return FileDownloader(
    authRepository: provideAuthRepository(),
  );
}

BiometricLocalAuthUtils provideBiometricLocalAuthUtils() {
  return BiometricLocalAuthUtils(
    localAuthentication: provideLocalAuthentication(),
    deviceInfoPlugin: DeviceInfoPlugin(),
  );
}

LocalAuthentication provideLocalAuthentication() {
  return LocalAuthentication();
}
