import 'package:der_die_das/app_theme.dart';
import 'package:der_die_das/models/word.dart';
import 'package:der_die_das/providers/game_session_provider.dart';
import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/models/game_state.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:der_die_das/providers/theme_provider.dart';
import 'package:der_die_das/providers/tts_provider.dart';
import 'package:der_die_das/services/ticker_service.dart';
import 'package:der_die_das/screens/home_screen.dart';
import 'package:der_die_das/providers/database_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:der_die_das/l10n/app_localizations.dart';
import '../helpers/test_mocks.dart';

class FakeGameSessionNotifier extends GameSessionNotifier {
  final GameState _initialState;
  FakeGameSessionNotifier(this._initialState);
  @override
  GameState build() => _initialState;
  @override
  Future<void> loadLevel(GameMode mode) async {}
}

class MockThemeNotifier extends ThemeNotifier {
  final AppTheme _fixedTheme;
  MockThemeNotifier(this._fixedTheme);
  @override
  AppTheme build() => _fixedTheme;
}

void main() {
  const channel = MethodChannel('window_manager');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'ensureInitialized') {
      return true;
    }
    if (methodCall.method == 'setMinimumSize') {
      return null;
    }
    if (methodCall.method == 'getSize') {
      return {'width': 800.0, 'height': 600.0};
    }
    if (methodCall.method == 'getPosition') {
      return {'x': 0.0, 'y': 0.0};
    }
    return null;
  });

  const dummyWord = Word(
    id: 1,
    word: 'Regenschirm',
    article: 'der',
    translations: {'cs': 'deštník', 'en': 'umbrella'},
    level: 'B1',
    category: 'Objects',
  );

  const testState = GameState(
    words: [dummyWord],
    currentIndex: 0,
    isLoading: false,
    score: 12,
    remainingTime: 15.5,
    gameMode: GameMode.survival,
  );

  testGoldens('Home Screen - Themes Comparison', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final mockTts = MockTtsService();
    final mockTimer = MockGameTimer();

    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 0.5);

    final testThemes = [
      AppTheme.light,
      AppTheme.dark,
      AppTheme.neon,
      AppTheme.forest
    ];

    for (var theme in testThemes) {
      builder.addScenario(
        'Theme: ${theme.name}',
        SizedBox(
          width: 450,
          height: 900,
          child: ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              vocabularyRepositoryProvider
                  .overrideWithValue(MockVocabularyRepository()),
              progressRepositoryProvider
                  .overrideWithValue(MockProgressRepository()),
              timerServiceProvider.overrideWithValue(mockTimer),
              gameSessionProvider
                  .overrideWith(() => FakeGameSessionNotifier(testState)),
              themeProvider.overrideWith(() => MockThemeNotifier(theme)),
              ttsServiceProvider.overrideWithValue(mockTts),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('cs')],
              theme: AppThemes.getThemeData(theme),
              debugShowCheckedModeBanner: false,
              home: const HomeScreen(),
            ),
          ),
        ),
      );
    }
    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(1000, 2000),
    );

    await screenMatchesGolden(tester, 'home_screen_comparison');
  });
}
