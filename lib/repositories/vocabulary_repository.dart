import 'package:flutter/foundation.dart';
import 'package:der_die_das/models/word.dart';
import 'package:der_die_das/services/vocabulary_database_service.dart';
import 'package:sqflite/sqflite.dart';

class VocabularyRepository {
  final VocabularyDatabaseService _databaseService;
  final Map<String, List<Word>> _levelCache = {};

  VocabularyRepository(this._databaseService);

  Future<List<Word>> getNounsForLevel(List<String> levels) async {
    final cacheKey = levels.join(',');
    if (_levelCache.containsKey(cacheKey)) {
      return List.from(_levelCache[cacheKey]!);
    }

    final db = await _databaseService.database;
    final whereClause = 'level IN (${levels.map((_) => '?').join(', ')})';
    final List<Map<String, dynamic>> maps = await db.query(
      'nouns',
      where: whereClause,
      whereArgs: levels,
    );

    // Optimization: Parse in a background isolate to prevent UI jank
    final result = await compute(_parseWords, maps);

    _levelCache[cacheKey] = result;
    return List.from(result);
  }

  // Must be static or top-level for compute
  static List<Word> _parseWords(List<Map<String, dynamic>> maps) {
    return maps.map((m) => Word.fromDb(m)).toList();
  }

  Future<int> getTotalWordCount() async {
    final db = await _databaseService.database;
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM nouns'));
    return count ?? 0;
  }

  Future<Map<String, int>> getWordDistributionBy(String column) async {
    const allowedColumns = {'level', 'category', 'article'};
    if (!allowedColumns.contains(column)) {
      throw ArgumentError('Invalid column name: $column');
    }

    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db
        .rawQuery('SELECT $column, COUNT(*) FROM nouns GROUP BY $column');
    final Map<String, int> distribution = {};
    for (var row in result) {
      distribution[row[column].toString()] = row['COUNT(*)'] as int;
    }
    return distribution;
  }
}
