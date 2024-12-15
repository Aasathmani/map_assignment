import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import "package:googleapis_auth/auth_io.dart";
import "package:http/http.dart" as http;
import 'package:map_assignment/src/core/app_constants.dart';
import 'package:map_assignment/src/core/exceptions.dart';
import 'package:map_assignment/src/domain/core/config_repository.dart';
import 'package:map_assignment/src/utils/extensions.dart';

class RemoteConfigService {
  final ConfigRepository configRepository;
  final AssetBundle assetBundle;

  RemoteConfigService({
    required this.configRepository,
    required this.assetBundle,
  });

  Future<Map<String, dynamic>> fetchRemoteConfigList() async {
    Response response;
    try {
      final firebaseApp = Firebase.app();

      final credentials = await fetchGoogleCredential();
      if (credentials == null) {
        return {};
      }

      final url = configRepository.restRemoteConfigUrl
          .replaceAll("{project_id}", firebaseApp.options.projectId);
      response = await NetworkClient.dioInstance.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${credentials.accessToken.data}',
          },
        ),
        queryParameters: {
          // 'key': key,
          'format': 'JSON',
        },
      );
    } catch (e) {
      throw CustomException(
        "FETCHING REMOTE CONFIG VIA API FAILED",
        message: e.toString(),
      );
    }

    return toGenericMap(response.data);
  }

  Future<AccessCredentials?> fetchGoogleCredential() async {
    final rcConfigString =
        await assetBundle.loadString('assets/rc_config/cx_falcon_desktop.json');

    final configMap = toGenericMap(json.decode(rcConfigString));

    // Use service account credentials to obtain oauth credentials.
    final accountCredentials = ServiceAccountCredentials.fromJson(configMap);
    final scopes = ['https://www.googleapis.com/auth/firebase.remoteconfig'];

    final client = http.Client();
    final credentials = await obtainAccessCredentialsViaServiceAccount(
      accountCredentials,
      scopes,
      client,
    );

    client.close();
    return credentials;
  }
}
