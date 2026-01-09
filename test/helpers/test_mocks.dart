import 'package:der_die_das/models/word.dart';
import 'package:der_die_das/providers/stats_provider.dart';
import 'package:der_die_das/repositories/progress_repository.dart';
import 'package:der_die_das/repositories/vocabulary_repository.dart';
import 'package:der_die_das/services/ticker_service.dart';
import 'package:der_die_das/services/tts_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockVocabularyRepository extends Mock implements VocabularyRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

class MockGameTimer extends Mock implements GameTimer {}

class MockTtsService extends Mock implements TtsService {}

class MockStatsNotifier extends AsyncNotifier<UserStats>
    with Mock
    implements StatsNotifier {
  @override
  Future<UserStats> build() async => const UserStats();
}

// Helper to provide a dummy word for tests
const dummyWord = Word(
  id: 1,
  word: 'Haus',
  article: 'das',
  translations: {'cs': 'dům', 'en': 'house', 'ru': 'дом'},
  level: 'A1',
  category: 'General',
);
