// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';

/// === DerDieDas Translator Tool (Legacy Fallback) ===
///
/// ⚠️ WARNING: This is a legacy fallback tool using the free MyMemory API.
/// It is NOT context-aware and often produces low-quality translations
/// (e.g., confusing "ruler" as "pravítko" instead of "vládce").
///
/// Recommended tool: tool/translate_with_gemini.dart
///
/// Usage:
///   dart tool/translate_csv.dart raw_data/vocabulary.csv ru
///

void main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart tool/translate_csv.dart <file_path> <target_lang>');
    print('Example: dart tool/translate_csv.dart raw_data/vocabulary.csv ru');
    return;
  }

  final filePath = args[0];
  final targetLang = args[1].toLowerCase();
  final file = File(filePath);

  if (!file.existsSync()) {
    print('Error: File not found: $filePath');
    return;
  }

  print('🔵 Processing $filePath for language: $targetLang');

  final lines = file.readAsLinesSync();
  if (lines.isEmpty) return;

  // Parse header
  var headerLine = lines[0];
  var header = headerLine.split(',').map((e) => e.trim()).toList();

  final targetColumnName = 'translation_$targetLang';
  int targetIndex = header.indexOf(targetColumnName);

  // If column doesn't exist, append it to the end
  if (targetIndex == -1) {
    print('🟡 Column $targetColumnName not found. Appending to the end.');
    header.add(targetColumnName);
    targetIndex = header.length - 1;
  } else {
    print('🔵 Column $targetColumnName exists at index $targetIndex.');
  }

  // Identify source column (German word is usually first, 'word')
  int sourceIndex = header.indexOf('word');
  if (sourceIndex == -1) sourceIndex = 0; // Fallback to first column

  final newLines = <String>[];
  newLines.add(header.join(','));

  final client = HttpClient();

  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty) continue;

    final parts = _splitCsv(line);

    // Extend row to match header length
    while (parts.length < header.length) {
      parts.add('');
    }

    final germanWord = parts[sourceIndex];
    String currentTranslation = parts[targetIndex].trim();

    if (currentTranslation.isEmpty || currentTranslation == '—') {
      print('🌐 Translating "$germanWord" to $targetLang...');
      try {
        var translatedText =
            await _translate(client, germanWord, 'de', targetLang);

        // Force lowercase as requested
        translatedText = translatedText.toLowerCase();

        parts[targetIndex] = translatedText;

        // Small delay to be polite to the API
        await Future<void>.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('🔴 Error translating $germanWord: $e');
      }
    }

    newLines.add(parts.join(','));
  }

  client.close();

  // Save back to file
  file.writeAsStringSync('${newLines.join('\n')}\n');
  print('\n✅ Done! Translated ${newLines.length - 1} words.');
}

List<String> _splitCsv(String line) {
  // Simple CSV split matching current format
  return line.split(',');
}

Future<String> _translate(
    HttpClient client, String text, String from, String to) async {
  final url = Uri.parse(
      'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=$from|$to');

  final request = await client.getUrl(url);
  final response = await request.close();
  final content = await response.transform(utf8.decoder).join();
  final data = json.decode(content);

  if (data['responseData'] != null) {
    return (data['responseData']['translatedText'] ?? '').toString();
  }
  return '';
}
