import 'package:der_die_das/repositories/vocabulary_repository.dart';
import 'package:der_die_das/services/vocabulary_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockVocabularyDatabaseService extends Mock
    implements VocabularyDatabaseService {}

void main() {
  late Database db;
  late MockVocabularyDatabaseService mockDatabaseService;
  late VocabularyRepository repository;

  setUp(() async {
    // Initialize FFI for tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Create in-memory database
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Create schema matching the real app
    await db.execute('''
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

    // Insert dummy data
    await db.insert('nouns', {
      'id': 1,
      'article': 'der',
      'word': 'Mann',
      'plural': 'Männer',
      'translation_cs': 'muž',
      'translation_en': 'man',
      'level': 'A1',
      'category': 'People',
      'tip': ''
    });
    await db.insert('nouns', {
      'id': 2,
      'article': 'die',
      'word': 'Frau',
      'plural': 'Frauen',
      'translation_cs': 'žena',
      'translation_en': 'woman',
      'level': 'A1',
      'category': 'People',
      'tip': ''
    });
    await db.insert('nouns', {
      'id': 3,
      'article': 'das',
      'word': 'Kind',
      'plural': 'Kinder',
      'translation_cs': 'dítě',
      'translation_en': 'child',
      'level': 'A2',
      'category': 'People',
      'tip': ''
    });

    mockDatabaseService = MockVocabularyDatabaseService();
    // When repository asks for vocab DB, give it our in-memory DB
    when(() => mockDatabaseService.database).thenAnswer((_) async => db);

    repository = VocabularyRepository(mockDatabaseService);
  });

  tearDown(() async {
    await db.close();
  });

  test('getNounsForLevel returns correct words for single level', () async {
    final words = await repository.getNounsForLevel(['A1']);
    expect(words.length, 2);
    expect(words.any((w) => w.word == 'Mann'), true);
    expect(words.any((w) => w.word == 'Frau'), true);
    expect(words.any((w) => w.word == 'Kind'), false);
  });

  test('getNounsForLevel returns correct words for multiple levels', () async {
    final words = await repository.getNounsForLevel(['A1', 'A2']);
    expect(words.length, 3);
  });

  test('getTotalWordCount returns correct count', () async {
    final count = await repository.getTotalWordCount();
    expect(count, 3);
  });

  test('getWordDistributionBy returns correct distribution', () async {
    final distribution = await repository.getWordDistributionBy('article');
    expect(distribution['der'], 1);
    expect(distribution['die'], 1);
    expect(distribution['das'], 1);
  });
}
