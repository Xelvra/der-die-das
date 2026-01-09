import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import 'shared_prefs_provider.dart';

class ThemeNotifier extends Notifier<AppTheme> {
  static const _key = 'app_theme';

  @override
  AppTheme build() {
    // Load initial value from SharedPreferences
    final prefs = ref.watch(sharedPreferencesProvider);
    final themeName = prefs.getString(_key);

    if (themeName != null) {
      return AppTheme.values.firstWhere(
        (e) => e.toString() == themeName,
        orElse: () => AppTheme.light,
      );
    }

    // First run: detect system brightness
    final brightness = PlatformDispatcher.instance.platformBrightness;
    if (brightness == Brightness.dark) {
      return AppTheme.dark;
    }

    return AppTheme.light;
  }

  void setTheme(AppTheme theme) {
    state = theme;
    ref.read(sharedPreferencesProvider).setString(_key, theme.toString());
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppTheme>(ThemeNotifier.new);
