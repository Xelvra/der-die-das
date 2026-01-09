// ignore_for_file: avoid_print

// === DerDieDas Database Builder ===
//
// This script generates the SQLite database from source CSV files.
// It is fully dynamic regarding translation columns.
//
// Usage:
//   dart run tool/build_database.dart
//
// Input:
//   - File: raw_data/vocabulary.csv
//   - Format: word,article,level,category,plural,translation_en,translation_cs,translation_ru...
//
// Output:
//   - File: assets/db/vocabulary.db

import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

// --- Configuration ---
const String csvFilePath = 'raw_data/vocabulary.csv';
const String dbDirPath = 'assets/db';
const String dbFilePath = '$dbDirPath/vocabulary.db';
const String tableName = 'nouns';

void main() {
  print('🔵 === DerDieDas Database Builder (Dynamic) ===\n');

  final csvFile = File(csvFilePath);
  if (!csvFile.existsSync()) {
    print('🔴 Error: Source file "$csvFilePath" not found!');
    exit(1);
  }

  // Ensure DB directory exists
  Directory(dbDirPath).createSync(recursive: true);

  final dbFile = File(dbFilePath);
  if (dbFile.existsSync()) {
    print('🟡 Warning: Database "$dbFilePath" already exists.');
    // In automated flows, we might want to skip user prompt, but here it's safer.
    // Uncomment for silent overwrite:
    // dbFile.deleteSync();
    stdout.write('Do you want to overwrite it? (y/N): ');
    final input = stdin.readLineSync()?.trim().toLowerCase();
    if (input != 'y' && input != 'yes') {
      print('🟡 Operation aborted by user.');
      exit(0);
    }
    print('🔵 -> Removing old database file...');
    dbFile.deleteSync();
  }

  print('Building database from: 🟢 $csvFilePath');

  // Open database
  final db = sqlite3.open(dbFilePath);

  try {
    // 1. Read CSV Header to Determine Structure
    print('🔵 -> Reading CSV structure...');
    final lines = csvFile.readAsLinesSync();

    if (lines.isEmpty) {
      print('🔴 Error: CSV file is empty.');
      db.close();
      exit(1);
    }

    final headerLine = lines[0];
    final header = headerLine.split(',').map((e) => e.trim()).toList();

    // Validate core columns
    if (!header.contains('word') || !header.contains('article')) {
      print(
          '🔴 Error: CSV must contain at least "word" and "article" columns.');
      exit(1);
    }

    // Identify dynamic translation columns
    final translationCols =
        header.where((col) => col.startsWith('translation_')).toList();
    print(
        '🔵 -> Found ${translationCols.length} translation languages: $translationCols');

    // 2. Construct Dynamic SQL for Table Creation
    // Fixed columns
    final StringBuffer createTableSql = StringBuffer();
    createTableSql.write('CREATE TABLE IF NOT EXISTS $tableName (');
    createTableSql.write('id INTEGER PRIMARY KEY AUTOINCREMENT, ');
    createTableSql.write('word TEXT NOT NULL, ');
    createTableSql.write('article TEXT NOT NULL, ');
    createTableSql.write('level TEXT, ');
    createTableSql.write('category TEXT, ');
    createTableSql.write('plural TEXT');

    // Add dynamic translation columns
    for (final col in translationCols) {
      createTableSql.write(', $col TEXT');
    }
    createTableSql.write(');');

    print('🔵 -> Creating table "$tableName"...');
    db.execute(createTableSql.toString());

    // 3. Construct Dynamic SQL for INSERT
    // All columns to insert (order matters for mapping values)
    final insertCols = [
      'word',
      'article',
      'level',
      'category',
      'plural',
      ...translationCols
    ];

    final placeholders = List.filled(insertCols.length, '?').join(', ');
    final insertSql =
        'INSERT INTO $tableName (${insertCols.join(', ')}) VALUES ($placeholders)';

    final stmt = db.prepare(insertSql);

    // Map column names to header indices for fast access
    final Map<String, int> colMap = {};
    for (int i = 0; i < header.length; i++) {
      colMap[header[i]] = i;
    }

    // Helper to safely get value by column name
    String getValue(List<String> parts, String colName) {
      if (!colMap.containsKey(colName)) return '';
      final index = colMap[colName]!;
      if (index >= parts.length) return '';
      return _clean(parts[index]);
    }

    // 4. Process Data
    final dataLines = lines.skip(1).where((l) => l.trim().isNotEmpty).toList();
    final totalLines = dataLines.length;

    print('🔵 -> Importing $totalLines words...');
    db.execute('BEGIN TRANSACTION;');

    int processed = 0;

    for (final line in dataLines) {
      final parts = line.split(',');

      // Expand parts if row is shorter than header
      while (parts.length < header.length) {
        parts.add('');
      }

      final word = getValue(parts, 'word');
      if (word.isEmpty) continue; // Skip invalid rows

      // Build argument list dynamically
      final args = <Object?>[];
      // Core fields
      args.add(word);
      args.add(getValue(parts, 'article'));
      args.add(getValue(parts, 'level'));
      args.add(getValue(parts, 'category'));
      args.add(getValue(parts, 'plural'));

      // Dynamic translations
      for (final tCol in translationCols) {
        args.add(getValue(parts, 'translation_en') == '' &&
                tCol == 'translation_en'
            ? getValue(parts,
                'translation_en') // Special case if EN is somehow empty? No, just copy.
            : getValue(parts, tCol));
      }

      stmt.execute(args);

      processed++;
      _printProgressBar(processed, totalLines);
    }

    db.execute('COMMIT;');
    stmt.close();

    print('\n\n🟢 Success! Database is ready at: $dbFilePath');
  } catch (e) {
    print('\n🔴 Error during database creation: $e');
    try {
      db.execute('ROLLBACK;');
    } catch (_) {}
    rethrow;
  } finally {
    db.close();
  }
}

String _clean(String input) {
  return input.trim().replaceAll('"', '').replaceAll("'", '');
}

void _printProgressBar(int current, int total) {
  const int width = 40;
  final percent = (current / total * 100).toInt();
  final filled = (current / total * width).toInt();
  final empty = width - filled;
  final bar = '█' * filled + '-' * empty;

  stdout.write('\rProgress: [$bar] $percent% ($current/$total)');
}
