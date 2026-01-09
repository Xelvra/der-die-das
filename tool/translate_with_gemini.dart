// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';

/// === DerDieDas AI Translator (Gemini) ===
///
/// This script uses Google's Gemini API to translate vocabulary with high accuracy.
/// It uses context (Article + Category) to disambiguate words (e.g., Bank -> Bench vs Bank).
///
/// Usage:
///   export GEMINI_API_KEY="your_api_key_here"
///   dart tool/translate_with_gemini.dart `<file_path>` `<target_lang>` [optional: --all]
///
/// Example:
///   dart tool/translate_with_gemini.dart raw_data/vocabulary.csv cs
///

const String _modelName =
    'gemini-1.5-flash'; // Cost-effective and fast for simple tasks
const int _batchSize = 30; // Number of words to send in one prompt

void main(List<String> args) async {
  // 1. Validate Arguments
  if (args.length < 2) {
    print(
        'Usage: dart tool/translate_with_gemini.dart <csv_file> <target_lang_code> [--all]');
    print(
        'Example: dart tool/translate_with_gemini.dart raw_data/vocabulary.csv cs');
    exit(1);
  }

  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('🔴 Error: GEMINI_API_KEY environment variable is not set.');
    print('Run: export GEMINI_API_KEY="your_key"');
    exit(1);
  }

  final filePath = args[0];
  final targetLang = args[1].toLowerCase();
  final forceAll =
      args.contains('--all'); // If present, re-translate everything

  final file = File(filePath);
  if (!file.existsSync()) {
    print('🔴 Error: File $filePath not found.');
    exit(1);
  }

  print('🔵 === Gemini AI Translator ===');
  print('Target Language: $targetLang');
  print('Model: $_modelName');
  print('Mode: ${forceAll ? "RE-TRANSLATE ALL" : "Only missing translations"}');

  // 2. Read and Parse CSV
  final lines = file.readAsLinesSync();
  if (lines.isEmpty) return;

  final header = lines[0].split(',').map((e) => e.trim()).toList();

  // Identify columns
  final wordIdx = header.indexOf('word');
  final articleIdx = header.indexOf('article');
  final categoryIdx = header.indexOf('category');

  if (wordIdx == -1 || articleIdx == -1 || categoryIdx == -1) {
    print(
        '🔴 Error: CSV must contain "word", "article", and "category" columns.');
    exit(1);
  }

  // Find or Create Target Column
  String targetColName = 'translation_$targetLang';
  int targetIdx = header.indexOf(targetColName);

  if (targetIdx == -1) {
    print('✨ Adding new column: $targetColName');
    header.add(targetColName);
    targetIdx = header.length - 1;
  }

  // Parse data into objects for easier handling
  List<List<String>> rows = [];
  List<int> indicesToTranslate = [];

  for (int i = 1; i < lines.length; i++) {
    var parts = _splitCsv(lines[i]);
    // Pad if necessary
    while (parts.length < header.length) {
      parts.add('');
    }
    rows.add(parts);

    final currentVal = parts[targetIdx].trim();
    if (forceAll || currentVal.isEmpty) {
      indicesToTranslate.add(i - 1); // -1 because rows list starts at line 1
    }
  }

  if (indicesToTranslate.isEmpty) {
    print('🟢 Nothing to translate.');
    return;
  }

  print('running translation for ${indicesToTranslate.length} words...');

  // 3. Process in Batches
  final client = HttpClient();

  for (int i = 0; i < indicesToTranslate.length; i += _batchSize) {
    final end = (i + _batchSize < indicesToTranslate.length)
        ? i + _batchSize
        : indicesToTranslate.length;
    final batchIndices = indicesToTranslate.sublist(i, end);

    await _processBatch(client, apiKey, rows, batchIndices, targetLang, wordIdx,
        articleIdx, categoryIdx, targetIdx);

    // Progress
    stdout.write(
        '\rProgress: $end / ${indicesToTranslate.length} words processed.');
  }

  client.close();

  // 4. Save File
  print('\n💾 Saving changes to $filePath...');
  final sb = StringBuffer();
  sb.writeln(header.join(','));
  for (final row in rows) {
    sb.writeln(row.join(','));
  }
  file.writeAsStringSync(sb.toString());
  print('✅ Done.');
}

/// Sends a batch of words to Gemini
Future<void> _processBatch(
  HttpClient client,
  String apiKey,
  List<List<String>> rows,
  List<int> batchIndices,
  String lang,
  int wIdx,
  int aIdx,
  int cIdx,
  int tIdx,
) async {
  // Construct the prompt content
  final List<Map<String, String>> itemsToTranslate = [];

  for (final idx in batchIndices) {
    itemsToTranslate.add({
      'id': idx.toString(), // We send ID to map it back easily
      'word': rows[idx][wIdx],
      'article': rows[idx][aIdx],
      'category': rows[idx][cIdx],
    });
  }

  final promptText = '''
You are a professional dictionary translator. 
Translate the following German words into $lang.
Use the provided 'article' and 'category' to determine the correct context and meaning.
Do NOT translate the article, only the noun.
Return a JSON object where keys are the 'id' provided and values are the translation.

Input Data:
${json.encode(itemsToTranslate)}

Output format (JSON only):
{
  "0": "translated_word",
  "1": "translated_word"
}
''';

  // Call API
  try {
    final responseJson = await _callGemini(client, apiKey, promptText);
    final Map<String, dynamic> translations =
        json.decode(responseJson) as Map<String, dynamic>;

    for (final idStr in translations.keys) {
      final idx = int.tryParse(idStr);
      if (idx != null) {
        // Clean up the translation (remove extra quotes, lowercase usually preferred for standard dicts,
        // but German nouns are capitalized. Target lang depends. Let's keep what AI gives or standard lowercase?)
        // The user previously wanted correct casing. Let's trust the AI but trim.
        rows[idx][tIdx] = translations[idStr].toString().trim().toLowerCase();
      }
    }
  } catch (e) {
    print('\n🔴 Batch Error: $e');
  }
}

Future<String> _callGemini(
    HttpClient client, String apiKey, String prompt) async {
  final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$apiKey');

  final request = await client.postUrl(uri);
  request.headers.contentType = ContentType.json;

  final payload = {
    'contents': [
      {
        'parts': [
          {'text': prompt}
        ]
      }
    ],
    'generationConfig': {'responseMimeType': 'application/json'}
  };

  request.write(json.encode(payload));
  final response = await request.close();

  if (response.statusCode != 200) {
    final err = await response.transform(utf8.decoder).join();
    throw Exception('API Error ${response.statusCode}: $err');
  }

  final responseBody = await response.transform(utf8.decoder).join();
  final data = json.decode(responseBody) as Map<String, dynamic>;

  // Extract text from Gemini response structure
  try {
    // Correctly cast and access nested elements
    final candidates = data['candidates'] as List<dynamic>;
    final firstCandidate = candidates[0] as Map<String, dynamic>;
    final content = firstCandidate['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    final firstPart = parts[0] as Map<String, dynamic>;
    return firstPart['text'] as String;
  } catch (e) {
    throw Exception('Malformed response: $responseBody');
  }
}

// Simple CSV splitter that respects basic commas
// Note: For complex CSVs with quoted commas, a real CSV parser library is better.
// Assuming the current dataset is simple.
List<String> _splitCsv(String line) {
  return line.split(',');
}
