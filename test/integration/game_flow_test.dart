import 'package:der_die_das/main.dart';
import 'package:der_die_das/models/word.dart';
import 'package:der_die_das/providers/database_providers.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:der_die_das/providers/tts_provider.dart';
import 'package:der_die_das/repositories/progress_repository.dart';
import 'package:der_die_das/repositories/vocabulary_repository.dart';
import 'package:der_die_das/screens/home_screen.dart';
import 'package:der_die_das/services/stt_service.dart';
import 'package:der_die_das/services/tts_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockVocabularyRepository extends Mock implements VocabularyRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

class MockTtsService extends Mock implements TtsService {}

class MockSttService extends Mock implements SttService {}

void main() {
  late MockVocabularyRepository mockVocabRepo;
  late MockProgressRepository mockProgressRepo;
  late MockTtsService mockTts;
  late MockSttService mockStt;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockVocabRepo = MockVocabularyRepository();
    mockProgressRepo = MockProgressRepository();
    mockTts = MockTtsService();
    mockStt = MockSttService();

    // Default Stubs
    when(() => mockVocabRepo.getNounsForLevel(any())).thenAnswer((_) async => [
          const Word(
              id: 1,
              word: 'Tisch',
              article: 'der',
              level: 'A1',
              category: 'furniture',
              translations: {'cs': 'stůl'}),
          const Word(
              id: 2,
              word: 'Lampe',
              article: 'die',
              level: 'A1',
              category: 'furniture',
              translations: {'cs': 'lampa'}),
        ]);
    when(() => mockVocabRepo.getTotalWordCount()).thenAnswer((_) async => 2);
    when(() => mockProgressRepo.getDueNouns(any())).thenAnswer((_) async => []);
    when(() => mockProgressRepo.getLearnedNouns()).thenAnswer((_) async => []);
    when(() => mockProgressRepo.getHardestNouns()).thenAnswer((_) async => []);
    when(() => mockProgressRepo.updateWordStatus(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockTts.speak(any())).thenAnswer((_) async {});
    when(() => mockTts.warmUp()).thenAnswer((_) async {});
    when(() => mockStt.setStatusListener(any())).thenAnswer((_) {});
    when(() => mockStt.stop()).thenAnswer((_) async {});
  });

  testWidgets(
      'Game Flow Integration Test: Start Game -> Answer Correct -> Next Word',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Setup App with Overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          vocabularyRepositoryProvider.overrideWithValue(mockVocabRepo),
          progressRepositoryProvider.overrideWithValue(mockProgressRepo),
          ttsServiceProvider.overrideWithValue(mockTts),
          sttServiceProvider.overrideWithValue(mockStt),
        ],
        child: const DerDieDasApp(),
      ),
    );

    // 2. Wait for Splash Screen to finish
    await tester.pumpAndSettle();

    // 3. We should be on HomeScreen. Check if we see "A1" or "Level"
    expect(find.byType(HomeScreen), findsOneWidget);

    // 4. Determine which word is shown (due to shuffling)
    final tischFinder = find.text('Tisch');
    final lampeFinder = find.text('Lampe');

    String expectedNextWord = '';
    LogicalKeyboardKey keyToPress =
        LogicalKeyboardKey.arrowRight; // Default der

    if (tischFinder.evaluate().isNotEmpty) {
      expectedNextWord = 'Lampe';
      keyToPress = LogicalKeyboardKey.arrowRight; // DER
    } else if (lampeFinder.evaluate().isNotEmpty) {
      expectedNextWord = 'Tisch';
      keyToPress = LogicalKeyboardKey.arrowLeft; // DIE
    } else {
      fail('Neither Tisch nor Lampe found on screen');
    }

    // 5. Simulate User Input
    await tester.sendKeyEvent(keyToPress);

    // 6. Verify UI reaction
    // Initial pump to process key event
    await tester.pump();

    // Wait for _kAnswerDisplayDuration (1000ms) + buffer
    await tester.pump(const Duration(milliseconds: 1100));

    // Wait for Swipe animation (approx 400-500ms) + buffer
    await tester.pump(const Duration(milliseconds: 600));

    // Wait for State update and rebuild
    await tester.pump();

    // 7. Verify transition
    // Note: If shuffle happened such that word 2 is same as word 1 (unlikely with 2 words distinct list shuffle, but possible if logic reloads?),
    // actually List..shuffle on [A, B] results in [A, B] or [B, A].
    // If we saw A, next MUST be B.

    expect(find.text(expectedNextWord), findsOneWidget);
  });
}
