import 'dart:async';

import 'package:map_assignment/config.dart';
import 'package:map_assignment/src/core/app.dart';

Future<void> main() async {
  Config.appFlavor = Production();
  await initApp();
}
