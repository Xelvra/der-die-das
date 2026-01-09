import 'package:freezed_annotation/freezed_annotation.dart';

part 'word.freezed.dart';
part 'word.g.dart';

// ignore: invalid_annotation_target
@freezed
abstract class Word with _$Word {
  const Word._(); // Required for adding methods to a Freezed class

  const factory Word({
    required int id,
    required String word,
    required String article,
    // Dynamic map of translations: 'cs' -> 'pes', 'en' -> 'dog'
    @Default({}) Map<String, String> translations,
    required String level,
    required String category,
    String? plural,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  /// Custom factory to parse flat DB structure into nested translations map
  factory Word.fromDb(Map<String, dynamic> map) {
    final translations = <String, String>{};

    // Iterate over all keys to find translation columns dynamically
    for (final key in map.keys) {
      if (key.startsWith('translation_')) {
        final langCode = key.replaceFirst('translation_', '');
        final value = map[key];
        if (value != null && value is String && value.isNotEmpty) {
          translations[langCode] = value;
        }
      }
    }

    return Word(
      id: map['id'] as int,
      word: map['word'] as String,
      article: map['article'] as String,
      translations: translations,
      level: map['level'] as String,
      category: map['category'] as String,
      plural: map['plural'] as String?,
    );
  }

  /// Helper to get translation safely. Returns empty string if not found.
  String getTranslation(String langCode) {
    return translations[langCode] ?? '';
  }
}
