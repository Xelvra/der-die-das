import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class StoragePathHelper {
  static bool _initialized = false;

  static void initDatabaseFactory() {
    if (_initialized) return;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  static Future<String> getDatabasePath(String dbName) async {
    if (!kIsWeb && Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final dbPath = join(home, '.local', 'share', 'com.derdiedas.app');
        // Ensure directory exists
        await Directory(dbPath).create(recursive: true);
        return join(dbPath, dbName);
      }
    }

    final dbPath = await getDatabasesPath();
    return join(dbPath, dbName);
  }
}
