

import 'package:map_assignment/src/core/app_constants.dart';
import 'package:map_assignment/src/domain/database/core/app_database.dart';
import 'package:map_assignment/src/utils/network_validator.dart';

class NotificationUtil {
  final NetworkValidator networkValidator;

  NotificationUtil({
    required this.networkValidator,
  });

  Future<NavigationData> processNotificationDeeplink({
    required User? user,
    required NotificationData notification,
  }) async {
    bool isNavigationNeeded = true;
    dynamic data;
    if ([
      DeepLinkType.profile,
    ].contains(notification.notificationType)) {
      await networkValidator.validateNetworkReachability();
    }

    if ([DeepLinkType.profile].contains(notification.notificationType)) {
      isNavigationNeeded = false;
    }

    return NavigationData(isNavigationNeeded: isNavigationNeeded, data: data);
  }
}

class NavigationData {
  dynamic data;
  bool isNavigationNeeded;

  NavigationData({
    required this.isNavigationNeeded,
    required this.data,
  });
}
