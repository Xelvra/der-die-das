import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_path_helper.dart';

class VocabularyDatabaseService {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    StoragePathHelper.initDatabaseFactory();
    final path = await StoragePathHelper.getDatabasePath('vocabulary.db');

    // Check for App Update to force DB refresh
    await _checkForAppUpdate(path);

    bool exists = await databaseExists(path);

    if (exists) {
      try {
        final db = await openDatabase(path, readOnly: true);
        final tables = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='nouns'");

        bool isValid = false;
        if (tables.isNotEmpty) {
          final count = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM nouns'));
          if (count != null && count > 0) {
            isValid = true;
          }
        }

        await db.close();

        if (!isValid) {
          if (kDebugMode) {
            print(
                'Vocabulary Database exists but is corrupted or empty. Re-copying from assets.');
          }
          await deleteDatabase(path);
          exists = false;
        }
      } catch (e) {
        if (kDebugMode) print('Database integrity check failed: $e');
        exists = false;
      }
    }

    if (!exists) {
      await _copyFromAssets(path);
    }

    return await openDatabase(path, readOnly: true);
  }

  Future<void> _checkForAppUpdate(String dbPath) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final prefs = await SharedPreferences.getInstance();

      // Combine version and build number to ensure uniqueness (e.g., "1.0.0+1")
      final currentVersion =
          '${packageInfo.version}+${packageInfo.buildNumber}';
      final lastKnownVersion = prefs.getString('pref_last_app_version');

      if (currentVersion != lastKnownVersion) {
        if (kDebugMode) {
          print(
              'App update detected ($lastKnownVersion -> $currentVersion). Refreshing Vocabulary DB.');
        }

        // If the file exists, delete it to force a re-copy from the new assets
        final file = File(dbPath);
        if (await file.exists()) {
          await file.delete();
        }

        // Save the new version
        await prefs.setString('pref_last_app_version', currentVersion);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking for app update: $e');
      }
      // If version check fails, we safely proceed without deleting DB
    }
  }

  Future<void> _copyFromAssets(String path) async {
    try {
      ByteData data =
          await rootBundle.load(join('assets', 'db', 'vocabulary.db'));
      Uint8List bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      if (kIsWeb) {
        await databaseFactory.writeDatabaseBytes(path, bytes);
      } else {
        // Directory creation is handled in StoragePathHelper for Linux,
        // but safe to ensure parent exists here too for other platforms.
        await Directory(dirname(path)).create(recursive: true);
        await File(path).writeAsBytes(bytes, flush: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error copying database: $e');
      }
      rethrow; // Important to propagate error so app knows DB failed
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
