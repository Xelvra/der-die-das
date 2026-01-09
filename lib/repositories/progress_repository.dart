import 'package:der_die_das/models/word.dart';
import 'package:der_die_das/services/user_database_service.dart';
import 'package:der_die_das/services/vocabulary_database_service.dart';
import 'package:sqflite/sqflite.dart';

class ProgressRepository {
  static const modeSurvival = 'survival';
  static const modeChallenge = 'challenge';

  // SRS Algorithm Constants (SM-2 based)
  static const double _kInitialDifficulty = 2.5;
  static const double _kMinDifficulty = 1.3;
  static const double _kDifficultyPenalty = 0.2;
  static const double _kFirstInterval = 1.0;
  static const double _kSecondInterval = 6.0;
  static const int _kMinReviewIntervalDays = 1;

  final UserDatabaseService _userDbService;
  final VocabularyDatabaseService _vocabDbService;

  ProgressRepository(this._userDbService, this._vocabDbService);

  Future<void> saveGameResult(
      String mode, int score, int durationSeconds) async {
    final db = await _userDbService.database;

    // 1. Insert the new result
    await db.insert('game_history', {
      'mode': mode,
      'score': score,
      'duration_seconds': durationSeconds,
      'played_at': DateTime.now().toIso8601String(),
    });

    // 2. Prune database: Keep only Top 50 scores for this mode
    await db.execute('''
      DELETE FROM game_history 
      WHERE mode = ? 
      AND id NOT IN (
        SELECT id FROM game_history 
        WHERE mode = ? 
        ORDER BY score DESC, duration_seconds ASC 
        LIMIT 50
      )
    ''', [mode, mode]);
  }

  Future<List<Map<String, dynamic>>> getTopScores(String mode,
      {int limit = 10}) async {
    final db = await _userDbService.database;
    // Check if table exists first (migration for existing users)
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='game_history'");
    if (tables.isEmpty) return [];

    return await db.query(
      'game_history',
      where: 'mode = ?',
      whereArgs: [mode],
      orderBy: 'score DESC, duration_seconds ASC',
      limit: limit,
    );
  }

  Future<int> getCurrentStreak() async {
    final db = await _userDbService.database;
    final result = await db.rawQuery(
        'SELECT DISTINCT SUBSTR(last_review, 1, 10) as day FROM word_status ORDER BY day DESC');

    if (result.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastActivityStr = result.first['day'] as String;
    final lastActivity = DateTime.parse(lastActivityStr);
    final lastActivityDate =
        DateTime(lastActivity.year, lastActivity.month, lastActivity.day);

    final diff = today.difference(lastActivityDate).inDays;

    if (diff > 1) return 0;
    if (diff == 0) streak = 1;
    if (diff == 1) streak = 1;

    for (int i = 0; i < result.length - 1; i++) {
      final d1Str = result[i]['day'] as String;
      final d2Str = result[i + 1]['day'] as String;

      final d1 = DateTime.parse(d1Str);
      final d2 = DateTime.parse(d2Str);

      final dayDiff = d1.difference(d2).inDays;
      if (dayDiff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<List<Word>> _fetchWordsByIds(List<int> ids,
      {List<String>? levels}) async {
    if (ids.isEmpty) return [];

    final vocabDb = await _vocabDbService.database;
    String whereClause = 'id IN (${ids.map((_) => '?').join(', ')})';
    List<dynamic> whereArgs = [...ids];

    if (levels != null && levels.isNotEmpty) {
      whereClause += ' AND level IN (${levels.map((_) => '?').join(', ')})';
      whereArgs.addAll(levels);
    }

    final List<Map<String, dynamic>> nounMaps = await vocabDb.query(
      'nouns',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return nounMaps.map((map) {
      return Word.fromDb(map);
    }).toList();
  }

  Future<List<Word>> getDueNouns(List<String> levels) async {
    final userDb = await _userDbService.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final List<Map<String, dynamic>> dueWordIdsMaps = await userDb.query(
      'word_status',
      columns: ['word_id'],
      where: 'due_date <= ?',
      whereArgs: [today],
    );

    final dueWordIds =
        dueWordIdsMaps.map((map) => map['word_id'] as int).toList();
    return _fetchWordsByIds(dueWordIds, levels: levels);
  }

  Future<List<Word>> getLearnedNouns() async {
    final userDb = await _userDbService.database;
    final List<Map<String, dynamic>> maps = await userDb.query(
      'word_status',
      columns: ['word_id'],
      where: 'reps > 0',
      limit: 50,
    );

    final ids = maps.map((m) => m['word_id'] as int).toList();
    return _fetchWordsByIds(ids);
  }

  Future<List<Word>> getHardestNouns() async {
    final userDb = await _userDbService.database;
    final List<Map<String, dynamic>> maps = await userDb.query(
      'word_status',
      columns: ['word_id'],
      where: 'wrong_count >= 2',
      orderBy: 'wrong_count DESC',
      limit: 50,
    );

    final ids = maps.map((m) => m['word_id'] as int).toList();
    return _fetchWordsByIds(ids);
  }

  Future<void> updateWordStatus(int wordId, bool isCorrect) async {
    final db = await _userDbService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'word_status',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );

    double difficulty = _kInitialDifficulty;
    int reps = 0;
    double stability = 0.0;
    int lapses = 0;
    int wrongCount = 0;

    if (maps.isNotEmpty) {
      difficulty = maps.first['difficulty'] as double;
      reps = maps.first['reps'] as int;
      stability = maps.first['stability'] as double;
      lapses = maps.first['lapses'] as int;
      wrongCount = maps.first['wrong_count'] as int? ?? 0;
    }

    if (isCorrect) {
      if (reps == 0) {
        stability = _kFirstInterval;
      } else if (reps == 1) {
        stability = _kSecondInterval;
      } else {
        stability = stability * difficulty;
      }
      reps += 1;
      if (wrongCount > 0) {
        wrongCount -= 1;
      }
    } else {
      reps = 0;
      stability = 0;
      lapses += 1;
      wrongCount += 1;
      difficulty = (difficulty - _kDifficultyPenalty)
          .clamp(_kMinDifficulty, _kInitialDifficulty);
    }

    if (difficulty < _kMinDifficulty) difficulty = _kMinDifficulty;

    // Fix: Ensure minimum interval is 1 day.
    // round() on 0.4 results in 0, causing immediate re-review.
    int intervalDays = stability.round();
    if (intervalDays < _kMinReviewIntervalDays) {
      intervalDays = _kMinReviewIntervalDays;
    }

    final nextReviewDate = DateTime.now().add(Duration(days: intervalDays));

    final values = {
      'word_id': wordId,
      'due_date': nextReviewDate.toIso8601String(),
      'stability': stability,
      'difficulty': difficulty,
      'lapses': lapses,
      'reps': reps,
      'wrong_count': wrongCount,
      'last_review': DateTime.now().toIso8601String(),
    };

    await db.insert(
      'word_status',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getLearnedWordsCount() async {
    final db = await _userDbService.database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM word_status WHERE reps > 0'));
    return count ?? 0;
  }
}
