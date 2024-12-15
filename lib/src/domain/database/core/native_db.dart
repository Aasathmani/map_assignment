// native.dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:map_assignment/src/domain/database/core/app_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

AppDatabase constructDb() {
  final db = LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = !kIsWeb && Platform.isWindows
        ? p.join(dbFolder.path, "/FESProject")
        : dbFolder.path;
    final file = File(p.join(path, 'db.sqlite'));
    return NativeDatabase(file);
  });
  return AppDatabase(db);
}
