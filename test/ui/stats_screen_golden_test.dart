import 'package:der_die_das/app_theme.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:der_die_das/providers/stats_provider.dart';
import 'package:der_die_das/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:der_die_das/l10n/app_localizations.dart';

class FakeStatsNotifier extends StatsNotifier {
  final UserStats _data;
  FakeStatsNotifier(this._data);
  @override
  UserStats build() => _data;
}

void main() {
  final fullStats = UserStats(
    totalWords: 1500,
    learnedWords: 1234,
    currentStreak: 42,
    survivalHighScores: List.generate(
        10,
        (i) => {
              'score': 100 - i,
              'duration_seconds': 60 + i,
              'played_at': '2026-01-01'
            }),
    challengeHighScores: [
      {'score': 500, 'duration_seconds': 30, 'played_at': '2026-01-01'}
    ],
    levelProgress: {'A1': 1.0, 'A2': 0.9, 'B1': 0.5},
  );

  const emptyStats = UserStats();

  testGoldens('Stats Screen - Full vs Empty', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 0.5)
      ..addScenario(
          'Full Stats (Midnight)',
          SizedBox(
            width: 450,
            height: 900,
            child: ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(prefs),
                statsProvider.overrideWith(() => FakeStatsNotifier(fullStats)),
              ],
              child: MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                supportedLocales: const [Locale('cs')],
                theme: AppThemes.getThemeData(AppTheme.midnight),
                debugShowCheckedModeBanner: false,
                home: const StatsScreen(),
              ),
            ),
          ))
      ..addScenario(
          'Empty Stats (Light)',
          SizedBox(
            width: 450,
            height: 900,
            child: ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(prefs),
                statsProvider.overrideWith(() => FakeStatsNotifier(emptyStats)),
              ],
              child: MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                supportedLocales: const [Locale('cs')],
                theme: AppThemes.getThemeData(AppTheme.light),
                debugShowCheckedModeBanner: false,
                home: const StatsScreen(),
              ),
            ),
          ));
    await tester.pumpWidgetBuilder(builder.build(),
        surfaceSize: const Size(1000, 1000));
    await screenMatchesGolden(tester, 'stats_screen_comparison');
  });

  testGoldens('Stats Screen - Challenge Tab', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    const fullStats = UserStats(
      survivalHighScores: [
        {'score': 10, 'duration_seconds': 10, 'played_at': '2026-01-01'}
      ],
      challengeHighScores: [
        {'score': 999, 'duration_seconds': 30, 'played_at': '2026-01-01'}
      ],
    );

    await tester.pumpWidgetBuilder(
      SizedBox(
        width: 450,
        height: 900,
        child: ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            statsProvider.overrideWith(() => FakeStatsNotifier(fullStats)),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: const [Locale('cs')],
            theme: AppThemes.getThemeData(AppTheme.nordic),
            debugShowCheckedModeBanner: false,
            home: const StatsScreen(),
          ),
        ),
      ),
      surfaceSize: const Size(500, 1000),
    );

    // Switch to Challenge tab
    await tester.tap(find.byType(Tab).at(1));
    await tester.pumpAndSettle();

    await screenMatchesGolden(tester, 'stats_screen_challenge_tab');
  });
}
