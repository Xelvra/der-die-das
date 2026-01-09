import 'package:der_die_das/app_theme.dart';
import 'package:der_die_das/help_screen.dart';
import 'package:der_die_das/widgets/loading_screen.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:der_die_das/l10n/app_localizations.dart';

void main() {
  testGoldens('Misc Screens - Loading and Help', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 0.5)
      ..addScenario(
          'Loading Screen',
          SizedBox(
            width: 450,
            height: 900,
            child: ProviderScope(
              overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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
                home: const LoadingScreen(currentTheme: AppTheme.nordic),
              ),
            ),
          ))
      ..addScenario(
          'Help Screen',
          SizedBox(
            width: 450,
            height: 900,
            child: ProviderScope(
              overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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
                home: const HelpScreen(),
              ),
            ),
          ));

    await tester.pumpWidgetBuilder(builder.build(),
        surfaceSize: const Size(1000, 1000));
    await screenMatchesGolden(tester, 'misc_screens',
        customPump: (tester) async => await tester.pump());
  });
}
