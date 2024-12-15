import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:map_assignment/src/core/exceptions.dart';

class NetworkValidator {
  final Connectivity connectivity;

  static NetworkValidator? instance;

  NetworkValidator({required this.connectivity});

  Future<void> validateNetworkReachability() async {
    final isReachable = await isNetworkReachable();
    if (!isReachable) {
      throw NoNetworkException();
    }
  }

  Future<bool> isNetworkReachable() async {
    final result = await connectivity.checkConnectivity();
    return isNetworkAvailable(result);
  }
}

bool isNetworkAvailable(ConnectivityResult result) {
  return [
    ConnectivityResult.mobile,
    ConnectivityResult.wifi,
  ].contains(result);
}
