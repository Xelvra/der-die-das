import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'app_locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final languageCode = prefs.getString(_key);

    if (languageCode != null) {
      return Locale(languageCode);
    }

    // First run: detect system language
    final systemLocale = PlatformDispatcher.instance.locale;
    return Locale(systemLocale.languageCode);
  }

  void setLocale(Locale locale) {
    state = locale;
    ref.read(sharedPreferencesProvider).setString(_key, locale.languageCode);
  }

  void toggleLocale() {
    if (state.languageCode == 'cs') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('cs'));
    }
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
