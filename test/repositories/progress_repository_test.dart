import 'package:der_die_das/repositories/progress_repository.dart';
import 'package:der_die_das/services/user_database_service.dart';
import 'package:der_die_das/services/vocabulary_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockUserDatabaseService extends Mock implements UserDatabaseService {}

class MockVocabularyDatabaseService extends Mock
    implements VocabularyDatabaseService {}

void main() {
  late Database userDb;
  late Database vocabDb;
  late MockUserDatabaseService mockUserDbService;
  late MockVocabularyDatabaseService mockVocabDbService;
  late ProgressRepository repository;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    userDb = await databaseFactory.openDatabase(inMemoryDatabasePath);
    vocabDb = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Schema for User DB
    await userDb.execute('''
      CREATE TABLE word_status (
        word_id INTEGER PRIMARY KEY,
        due_date TEXT NOT NULL,
        stability REAL NOT NULL,
        difficulty REAL NOT NULL,
        lapses INTEGER DEFAULT 0,
        reps INTEGER DEFAULT 0,
        wrong_count INTEGER DEFAULT 0,
        last_review TEXT
      )
    ''');
    await userDb.execute('''
      CREATE TABLE game_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mode TEXT NOT NULL,
        score INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        played_at TEXT NOT NULL
      )
    ''');

    // Schema for Vocab DB (needed for joins in getDueNouns)
    await vocabDb.execute('''
       CREATE TABLE nouns (
        id INTEGER PRIMARY KEY,
        article TEXT,
        word TEXT,
        plural TEXT,
        translation_cs TEXT,
        translation_en TEXT,
        level TEXT,
        category TEXT,
        tip TEXT
      )
    ''');
    await vocabDb.insert('nouns', {
      'id': 1,
      'article': 'der',
      'word': 'Test',
      'plural': '',
      'translation_cs': '',
      'translation_en': '',
      'level': 'A1',
      'category': '',
      'tip': ''
    });

    mockUserDbService = MockUserDatabaseService();
    mockVocabDbService = MockVocabularyDatabaseService();

    when(() => mockUserDbService.database).thenAnswer((_) async => userDb);
    when(() => mockVocabDbService.database).thenAnswer((_) async => vocabDb);

    repository = ProgressRepository(mockUserDbService, mockVocabDbService);
  });

  tearDown(() async {
    await userDb.close();
    await vocabDb.close();
  });

  group('SM-2 Algorithm Tests', () {
    test('First correct answer sets initial stability', () async {
      await repository.updateWordStatus(1, true);

      final result = await userDb.query('word_status', where: 'word_id = 1');
      expect(result.isNotEmpty, true);
      final row = result.first;

      expect(row['reps'], 1);
      expect(row['stability'], 1.0); // First interval is 1 day
      expect(row['lapses'], 0);

      // Due date should be tomorrow (roughly)
      final dueDate = DateTime.parse(row['due_date'] as String);
      final now = DateTime.now();
      expect(dueDate.isAfter(now), true);
    });

    test('Second correct answer increases stability to 6', () async {
      // Simulate first rep
      await userDb.insert('word_status', {
        'word_id': 1,
        'due_date': '2023-01-01',
        'stability': 1.0,
        'difficulty': 2.5,
        'reps': 1,
        'lapses': 0,
        'last_review': '2023-01-01'
      });

      await repository.updateWordStatus(1, true);

      final result = await userDb.query('word_status', where: 'word_id = 1');
      final row = result.first;

      expect(row['reps'], 2);
      expect(row['stability'], 6.0); // SM-2 rule: 2nd rep -> 6 days
    });

    test('Incorrect answer resets stability and increases lapses', () async {
      // Simulate learned word
      await userDb.insert('word_status', {
        'word_id': 1,
        'due_date': '2023-01-01',
        'stability': 10.0,
        'difficulty': 2.5,
        'reps': 5,
        'lapses': 0,
        'wrong_count': 0,
        'last_review': '2023-01-01'
      });

      await repository.updateWordStatus(1, false);

      final result = await userDb.query('word_status', where: 'word_id = 1');
      final row = result.first;

      expect(row['reps'], 0); // Reset reps
      expect(row['stability'], 0.0); // Reset interval
      expect(row['lapses'], 1); // Increment lapses
      expect(row['wrong_count'], 1);
      // Difficulty should decrease
      expect((row['difficulty'] as double) < 2.5, true);
    });
  });

  group('Game History Tests', () {
    test('saveGameResult saves score and limits history', () async {
      // Insert 55 dummy records
      for (int i = 0; i < 55; i++) {
        await repository.saveGameResult('survival', i, 10);
      }

      final count = Sqflite.firstIntValue(await userDb
          .rawQuery("SELECT COUNT(*) FROM game_history WHERE mode='survival'"));
      expect(count, 50); // Should be capped at 50

      final topScores = await repository.getTopScores('survival');
      expect(topScores.first['score'], 54); // Highest score should be first
    });
  });

  group('Streak Tests', () {
    test('getCurrentStreak calculates simple streak', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      await userDb.insert('word_status', {
        'word_id': 1,
        'due_date': '',
        'stability': 0,
        'difficulty': 0,
        'last_review': now.toIso8601String()
      });
      await userDb.insert('word_status', {
        'word_id': 2,
        'due_date': '',
        'stability': 0,
        'difficulty': 0,
        'last_review': yesterday.toIso8601String()
      });

      final streak = await repository.getCurrentStreak();
      expect(streak, 2);
    });
  });
}
