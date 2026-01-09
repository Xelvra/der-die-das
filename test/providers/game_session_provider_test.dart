import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/providers/database_providers.dart';
import 'package:der_die_das/providers/game_session_provider.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:der_die_das/providers/stats_provider.dart';
import 'package:der_die_das/services/ticker_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/test_mocks.dart';

void main() {
  late MockVocabularyRepository mockVocabRepo;
  late MockProgressRepository mockProgressRepo;
  late MockGameTimer mockGameTimer;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  setUp(() async {
    mockVocabRepo = MockVocabularyRepository();
    mockProgressRepo = MockProgressRepository();
    mockGameTimer = MockGameTimer();

    // Default stub for timer
    when(() => mockGameTimer.startPeriodic(any(), any())).thenReturn(null);
    when(() => mockGameTimer.cancel()).thenReturn(null);

    // Mock Shared Preferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        vocabularyRepositoryProvider.overrideWithValue(mockVocabRepo),
        progressRepositoryProvider.overrideWithValue(mockProgressRepo),
        timerServiceProvider.overrideWithValue(mockGameTimer),
        statsProvider.overrideWith(() => MockStatsNotifier()),
      ],
    );
  });

  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    container.dispose();
  });

  test('Initial state is correct', () async {
    final state = container.read(gameSessionProvider);
    expect(state.isLoading, true);

    await Future<void>.delayed(const Duration(milliseconds: 50));
  });

  test('loadLevel loads words and updates state', () async {
    when(() => mockProgressRepo.getDueNouns(any())).thenAnswer((_) async => []);
    when(() => mockVocabRepo.getNounsForLevel(any()))
        .thenAnswer((_) async => [dummyWord]);

    container.read(gameSessionProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await container.read(gameSessionProvider.notifier).loadLevel(GameMode.a1);

    final state = container.read(gameSessionProvider);
    expect(state.isLoading, false);
    expect(state.words.length, 1);
    expect(state.currentWord, dummyWord);
  });

  test('submitAnswer correct updates database and state (Survival)', () async {
    final notifier = container.read(gameSessionProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    when(() => mockVocabRepo.getNounsForLevel(any()))
        .thenAnswer((_) async => [dummyWord]);
    when(() => mockProgressRepo.updateWordStatus(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockProgressRepo.saveGameResult(any(), any(), any()))
        .thenAnswer((_) async {});

    await notifier.loadLevel(GameMode.survival);

    expect(container.read(gameSessionProvider).score, 0);

    await notifier.submitAnswer('das');

    verify(() => mockProgressRepo.updateWordStatus(1, true)).called(1);
    expect(container.read(gameSessionProvider).score, 1);
  });

  test('submitAnswer incorrect updates database and penalizes time (Survival)',
      () async {
    final notifier = container.read(gameSessionProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    when(() => mockVocabRepo.getNounsForLevel(any()))
        .thenAnswer((_) async => [dummyWord]);
    when(() => mockProgressRepo.updateWordStatus(any(), any()))
        .thenAnswer((_) async {});

    await notifier.loadLevel(GameMode.survival);

    await notifier.submitAnswer('der');

    verify(() => mockProgressRepo.updateWordStatus(1, false)).called(1);
    expect(container.read(gameSessionProvider).score, 0);
  });
}
