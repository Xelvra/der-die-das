import 'package:der_die_das/app_theme.dart';
import 'package:der_die_das/l10n/app_localizations.dart';
import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/models/word.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:der_die_das/providers/theme_provider.dart';
import 'package:der_die_das/providers/tts_provider.dart';
import 'package:der_die_das/services/tts_service.dart';
import 'package:der_die_das/widgets/word_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockThemeNotifier extends ThemeNotifier {
  final AppTheme _initialTheme;
  MockThemeNotifier(this._initialTheme);
  @override
  AppTheme build() => _initialTheme;
}

class MockTtsService extends Mock implements TtsService {}

void main() {
  testGoldens('WordCard - Matrix Test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final mockTts = MockTtsService();

    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 0.65);

    const words = [
      Word(
          id: 1,
          word: 'Tisch',
          article: 'der',
          translations: {'cs': 'stůl', 'en': 'table'},
          level: 'A1',
          category: 'X'),
      Word(
          id: 2,
          word: 'Tür',
          article: 'die',
          translations: {'cs': 'dveře', 'en': 'door'},
          level: 'A1',
          category: 'X'),
      Word(
          id: 3,
          word: 'Fenster',
          article: 'das',
          translations: {'cs': 'okno', 'en': 'window'},
          level: 'A1',
          category: 'X'),
    ];

    final themes = [
      AppTheme.light,
      AppTheme.dark,
      AppTheme.sepia,
      AppTheme.neon
    ];

    for (var theme in themes) {
      for (var word in words) {
        builder.addScenario(
          '${theme.name} - ${word.article}',
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              themeProvider.overrideWith(() => MockThemeNotifier(theme)),
              ttsServiceProvider.overrideWithValue(mockTts),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppThemes.getThemeData(theme),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('cs')],
              home: Material(
                  child: WordCard(
                      word: word,
                      showCardAnswer: true,
                      gameMode: GameMode.a1,
                      width: 200,
                      height: 300)),
            ),
          ),
        );
      }
    }

    // Feedback states
    builder.addScenario(
      'Correct Answer (Green)',
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsServiceProvider.overrideWithValue(mockTts),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemes.getThemeData(AppTheme.nordic),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('cs')],
          home: Material(
            child: WordCard(
                word: words[0],
                showCardAnswer: true,
                gameMode: GameMode.a1,
                backgroundColor: Colors.green.shade200,
                width: 200,
                height: 300),
          ),
        ),
      ),
    );

    builder.addScenario(
      'Incorrect Answer (Red)',
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsServiceProvider.overrideWithValue(mockTts),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemes.getThemeData(AppTheme.nordic),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('cs')],
          home: Material(
            child: WordCard(
                word: words[0],
                showCardAnswer: true,
                gameMode: GameMode.a1,
                backgroundColor: Colors.red.shade200,
                width: 200,
                height: 300),
          ),
        ),
      ),
    );

    // Card Back
    builder.addScenario(
      'Card Back (LOD)',
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsServiceProvider.overrideWithValue(mockTts),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemes.getThemeData(AppTheme.nordic),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('cs')],
          home: Material(
            child: WordCard(
                word: words[0],
                isBackgroundCard: true,
                gameMode: GameMode.a1,
                width: 200,
                height: 300),
          ),
        ),
      ),
    );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(1000, 1500),
    );

    await screenMatchesGolden(tester, 'word_card_matrix');
  });
}
