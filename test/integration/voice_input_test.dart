import 'package:der_die_das/main.dart';
import 'package:der_die_das/models/word.dart';
import 'package:der_die_das/providers/database_providers.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:der_die_das/providers/tts_provider.dart';
import 'package:der_die_das/repositories/progress_repository.dart';
import 'package:der_die_das/repositories/vocabulary_repository.dart';
import 'package:der_die_das/services/game_timer_service.dart';
import 'package:der_die_das/services/stt_service.dart';
import 'package:der_die_das/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class MockVocabularyRepository extends Mock implements VocabularyRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

class MockTtsService extends Mock implements TtsService {}

class MockSttService extends Mock implements SttService {}

class MockGameTimerService extends Mock implements GameTimerService {}

void main() {
  late MockVocabularyRepository mockVocabRepo;
  late MockProgressRepository mockProgressRepo;
  late MockTtsService mockTts;
  late MockSttService mockStt;
  late MockGameTimerService mockTimer;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'speech_recognition_enabled': true,
    });
    mockVocabRepo = MockVocabularyRepository();
    mockProgressRepo = MockProgressRepository();
    mockTts = MockTtsService();
    mockStt = MockSttService();
    mockTimer = MockGameTimerService();

    when(() => mockVocabRepo.getNounsForLevel(any())).thenAnswer((_) async => [
          const Word(
              id: 1,
              word: 'Tisch',
              article: 'der',
              level: 'A1',
              category: 'furniture',
              translations: {}),
        ]);
    when(() => mockProgressRepo.getDueNouns(any())).thenAnswer((_) async => []);

    // Stats Mocks
    when(() => mockVocabRepo.getTotalWordCount()).thenAnswer((_) async => 100);
    when(() => mockProgressRepo.getLearnedWordsCount())
        .thenAnswer((_) async => 0);
    when(() => mockProgressRepo.getCurrentStreak()).thenAnswer((_) async => 0);
    when(() => mockProgressRepo.getTopScores(any()))
        .thenAnswer((_) async => []);

    when(() => mockTts.warmUp()).thenAnswer((_) async {});
    when(() => mockStt.setStatusListener(any())).thenAnswer((_) {});
    when(() => mockStt.stop()).thenAnswer((_) async {});
    when(() => mockTimer.cancel()).thenReturn(null);
    when(() => mockTimer.timeStream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('Voice Input Icon Visibility Test', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          vocabularyRepositoryProvider.overrideWithValue(mockVocabRepo),
          progressRepositoryProvider.overrideWithValue(mockProgressRepo),
          ttsServiceProvider.overrideWithValue(mockTts),
          sttServiceProvider.overrideWithValue(mockStt),
          gameTimerServiceProvider.overrideWithValue(mockTimer),
        ],
        child: const DerDieDasApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    final micIcon = find.byIcon(Icons.mic);

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      // On Desktop, mic should be hidden even if enabled in settings
      expect(micIcon, findsNothing);
    } else {
      // On Mobile, mic should be visible
      expect(micIcon, findsOneWidget);
    }
  });
}
