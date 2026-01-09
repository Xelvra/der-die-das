// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Word _$WordFromJson(Map<String, dynamic> json) => _Word(
      id: (json['id'] as num).toInt(),
      word: json['word'] as String,
      article: json['article'] as String,
      translations: (json['translations'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      level: json['level'] as String,
      category: json['category'] as String,
      plural: json['plural'] as String?,
    );

Map<String, dynamic> _$WordToJson(_Word instance) => <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'article': instance.article,
      'translations': instance.translations,
      'level': instance.level,
      'category': instance.category,
      'plural': instance.plural,
    };
