import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/models/word.dart';
import 'package:der_die_das/providers/database_providers.dart';
import 'package:der_die_das/providers/game_session_provider.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:der_die_das/repositories/progress_repository.dart';
import 'package:der_die_das/repositories/vocabulary_repository.dart';
import 'package:der_die_das/services/game_timer_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockVocabularyRepository extends Mock implements VocabularyRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

class MockGameTimerService extends Mock implements GameTimerService {}

void main() {
  late MockVocabularyRepository mockVocabRepo;
  late MockProgressRepository mockProgressRepo;
  late MockGameTimerService mockTimerService;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    mockVocabRepo = MockVocabularyRepository();
    mockProgressRepo = MockProgressRepository();
    mockTimerService = MockGameTimerService();

    when(() => mockVocabRepo.getNounsForLevel(any())).thenAnswer((_) async => [
          const Word(
              id: 1,
              word: 'Tisch',
              article: 'der',
              level: 'A1',
              category: 'furniture',
              translations: {}),
          const Word(
              id: 2,
              word: 'Lampe',
              article: 'die',
              level: 'A1',
              category: 'furniture',
              translations: {}),
        ]);

    when(() => mockProgressRepo.getDueNouns(any())).thenAnswer((_) async => []);
    when(() => mockProgressRepo.getLearnedNouns()).thenAnswer((_) async => []);
    when(() => mockProgressRepo.getHardestNouns()).thenAnswer((_) async => []);
    when(() => mockProgressRepo.updateWordStatus(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockProgressRepo.saveGameResult(any(), any(), any()))
        .thenAnswer((_) async {});

    when(() => mockTimerService.start(any(), any(), any(),
        fastMode: any(named: 'fastMode'))).thenAnswer((_) {});

    when(() => mockTimerService.cancel()).thenReturn(null);

    container = ProviderContainer(
      overrides: [
        vocabularyRepositoryProvider.overrideWithValue(mockVocabRepo),
        progressRepositoryProvider.overrideWithValue(mockProgressRepo),
        gameTimerServiceProvider.overrideWithValue(mockTimerService),
        sharedPreferencesProvider.overrideWithValue(
            prefs), // FIXED: Missing override caused UnimplementedError
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state should be loading by default', () {
    final state = container.read(gameSessionProvider);
    expect(state.isLoading, true);
    expect(state.words, isEmpty);
  });

  test('loadLevel initializes game correctly', () async {
    final notifier = container.read(gameSessionProvider.notifier);

    await notifier.loadLevel(GameMode.survival);

    final state = container.read(gameSessionProvider);
    expect(state.isLoading, false);
    expect(state.words.length, 2);
    expect(state.gameMode, GameMode.survival);
    expect(state.remainingTime, 60.0);
    expect(state.score, 0);

    verify(() => mockTimerService.start(60.0, 60.0, any(),
        fastMode: any(named: 'fastMode'))).called(1);
  });

  test('Submit correct answer increases score in Survival', () async {
    final notifier = container.read(gameSessionProvider.notifier);
    await notifier.loadLevel(GameMode.survival);

    final stateLoaded = container.read(gameSessionProvider);
    if (stateLoaded.words.isEmpty) fail('Words not loaded - Setup failed');

    final initialScore = stateLoaded.score;
    final currentWord = stateLoaded.currentWord!;

    await notifier.submitAnswer(currentWord.article);

    final state = container.read(gameSessionProvider);
    expect(state.score, initialScore + 1);
    expect(state.remainingTime, 60.0);
  });

  test('Submit wrong answer decreases time in Survival', () async {
    final notifier = container.read(gameSessionProvider.notifier);
    await notifier.loadLevel(GameMode.survival);

    final stateLoaded = container.read(gameSessionProvider);
    if (stateLoaded.words.isEmpty) fail('Words not loaded - Setup failed');

    final currentWord = stateLoaded.currentWord!;
    final wrongArticle = currentWord.article == 'der' ? 'die' : 'der';

    await notifier.submitAnswer(wrongArticle);

    final state = container.read(gameSessionProvider);
    expect(state.score, 0);
    expect(state.remainingTime, 57.0); // 60 - 3
  });

  // --- Challenge Mode Tests ---

  test('loadLevel initializes Challenge mode correctly (25 points, no timer)',
      () async {
    final notifier = container.read(gameSessionProvider.notifier);

    await notifier.loadLevel(GameMode.challenge);

    final state = container.read(gameSessionProvider);
    expect(state.isLoading, false);
    expect(state.gameMode, GameMode.challenge);
    expect(state.remainingTime, 25.0); // Starts at 25
    expect(state.maxTime, 50.0); // Max is 50

    // Ensure timer is NOT started for Challenge mode
    verifyNever(() => mockTimerService.start(any(), any(), any(),
        fastMode: any(named: 'fastMode')));
  });

  test('Submit correct answer in Challenge adds 5 points', () async {
    final notifier = container.read(gameSessionProvider.notifier);
    await notifier.loadLevel(GameMode.challenge);

    final stateLoaded = container.read(gameSessionProvider);
    final currentWord = stateLoaded.currentWord!;

    await notifier.submitAnswer(currentWord.article);

    final state = container.read(gameSessionProvider);
    expect(state.score, 1);
    expect(state.remainingTime, 30.0); // 25 + 5
  });

  test('Submit wrong answer in Challenge subtracts 5 points', () async {
    final notifier = container.read(gameSessionProvider.notifier);
    await notifier.loadLevel(GameMode.challenge);

    final stateLoaded = container.read(gameSessionProvider);
    final currentWord = stateLoaded.currentWord!;
    final wrongArticle = currentWord.article == 'der' ? 'die' : 'der';

    await notifier.submitAnswer(wrongArticle);

    final state = container.read(gameSessionProvider);
    expect(state.score, 0);
    expect(state.remainingTime, 20.0); // 25 - 5
  });

  test('Challenge ends when points drop to 0', () async {
    final notifier = container.read(gameSessionProvider.notifier);
    await notifier.loadLevel(GameMode.challenge);

    // Manually set low points via a wrong answer scenario or mock,
    // but here we can just simulate enough wrong answers.
    // Starting at 25. We need 5 wrong answers (5 * 5 = 25) to die.

    final stateLoaded = container.read(gameSessionProvider);
    final currentWord = stateLoaded.currentWord!;
    final wrongArticle = currentWord.article == 'der' ? 'die' : 'der';

    // 1. Wrong (-5) -> 20
    await notifier.submitAnswer(wrongArticle);
    // 2. Wrong (-5) -> 15
    await notifier.submitAnswer(wrongArticle);
    // 3. Wrong (-5) -> 10
    await notifier.submitAnswer(wrongArticle);
    // 4. Wrong (-5) -> 5
    await notifier.submitAnswer(wrongArticle);
    // 5. Wrong (-5) -> 0 -> Game Over
    await notifier.submitAnswer(wrongArticle);

    final state = container.read(gameSessionProvider);
    expect(state.remainingTime, 0.0);
    expect(state.isGameOver, true);
  });
}
