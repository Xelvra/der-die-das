import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:der_die_das/providers/theme_provider.dart';
import 'package:der_die_das/providers/settings_provider.dart';
import 'package:der_die_das/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:der_die_das/l10n/app_localizations.dart';
import 'package:der_die_das/providers/locale_provider.dart';
import 'package:der_die_das/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:der_die_das/widgets/inactivity_dimmer.dart';
// Import the existing provider that handles window logic
import 'package:der_die_das/providers/window_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Desktop window configuration (Initialization only)
  // We read initial values here to prevent flickering on startup,
  // but logic for saving changes stays in WindowProvider.
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    double? width = prefs.getDouble('window_width');
    double? height = prefs.getDouble('window_height');
    double? x = prefs.getDouble('window_x');
    double? y = prefs.getDouble('window_y');

    if (width == null || width < 320) width = 480;
    if (height == null || height < 480) height = 640;

    final WindowOptions windowOptions = WindowOptions(
      size: Size(width, height),
      minimumSize: const Size(320, 480),
      center: x == null || y == null,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (x != null && y != null && x > -5000 && y > -5000) {
        await windowManager.setPosition(Offset(x, y));
      }
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const DerDieDasApp(),
    ),
  );
}

class DerDieDasApp extends ConsumerWidget {
  const DerDieDasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Core Providers
    final currentTheme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final settings = ref.watch(settingsProvider);

    // 2. Activate Window Manager Logic (Desktop only)
    // By watching this provider, we ensure the listener for window changes is active.
    // The provider itself handles the "business logic" of saving to SharedPreferences.
    ref.watch(windowProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.getThemeData(currentTheme),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      builder: (context, child) {
        return InactivityDimmer(
          enabled: settings.isPowerSavingEnabled,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
