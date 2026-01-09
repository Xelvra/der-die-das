// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';

/// === DerDieDas ARB Generator ===
///
/// This script ensures that for every language found in the vocabulary CSV,
/// there is a corresponding .arb file in lib/l10n/.
///
/// If an .arb file is missing, it creates one by copying app_en.arb
/// and updating the @@locale key.
///
/// Usage:
///   dart tool/generate_arb_from_csv.dart
///

const String csvFilePath = 'raw_data/vocabulary.csv';
const String l10nDirPath = 'lib/l10n';
const String templateArbPath = '$l10nDirPath/app_en.arb';

void main() {
  print('🔵 === DerDieDas ARB Generator ===\n');

  final csvFile = File(csvFilePath);
  if (!csvFile.existsSync()) {
    print('🔴 Error: CSV file "$csvFilePath" not found!');
    exit(1);
  }

  // 1. Find languages in CSV
  final lines = csvFile.readAsLinesSync();
  if (lines.isEmpty) return;

  final List<String> header = lines[0].split(',').map((e) => e.trim()).toList();
  final Set<String> languages = <String>{};

  for (final col in header) {
    if (col.startsWith('translation_')) {
      final lang = col.replaceFirst('translation_', '');
      languages.add(lang);
    }
  }

  print('🔎 Found languages in CSV: $languages');

  // 2. Check and generate ARB files
  final templateFile = File(templateArbPath);
  if (!templateFile.existsSync()) {
    print('🔴 Error: Template ARB file "$templateArbPath" not found!');
    exit(1);
  }

  final templateContent = templateFile.readAsStringSync();
  final Map<String, dynamic> templateJson =
      json.decode(templateContent) as Map<String, dynamic>;

  int createdCount = 0;

  for (final lang in languages) {
    final arbFilePath = '$l10nDirPath/app_$lang.arb';
    final arbFile = File(arbFilePath);

    if (!arbFile.existsSync()) {
      print('✨ Generating missing ARB file for: $lang');

      // Create copy
      final Map<String, dynamic> newJson =
          Map<String, dynamic>.from(templateJson);
      newJson['@@locale'] = lang;

      // Write with indentation for readability
      const encoder = JsonEncoder.withIndent('  ');
      arbFile.writeAsStringSync(encoder.convert(newJson));
      createdCount++;
    } else {
      print('✅ ARB file exists for: $lang');
    }
  }

  if (createdCount > 0) {
    print('\n🟢 Created $createdCount new ARB files.');
    print('👉 Run "flutter gen-l10n" or build the app to register them.');
  } else {
    print('\n🟢 All ARB files are up to date.');
  }
}
