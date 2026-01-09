import 'package:der_die_das/app_drawer.dart';
import 'package:der_die_das/app_theme.dart';
import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:der_die_das/l10n/app_localizations.dart';

void main() {
  testGoldens('App Drawer - L10n Test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 0.5);

    for (var locale in [const Locale('cs'), const Locale('en')]) {
      builder.addScenario(
        'Drawer (${locale.languageCode})',
        SizedBox(
          width: 300,
          height: 800,
          child: ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              supportedLocales: const [Locale('cs'), Locale('en')],
              locale: locale,
              theme: AppThemes.getThemeData(AppTheme.nordic),
              debugShowCheckedModeBanner: false,
              home: Material(
                child: AppDrawer(
                    currentMode: GameMode.survival,
                    selectedLevel: GameMode.a1,
                    onModeChanged: (_) {}),
              ),
            ),
          ),
        ),
      );
    }

    // Special logic to open drawers in the test grid
    // Note: In golden tests, we need to pump each scenario.
    // For simplicity, we'll just render the Drawer widget directly as a child of a Container.

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(1000, 1000),
    );

    await screenMatchesGolden(tester, 'app_drawer_l10n');
  });
}
