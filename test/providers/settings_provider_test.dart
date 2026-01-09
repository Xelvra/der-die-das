import 'package:der_die_das/models/card_style.dart';
import 'package:der_die_das/providers/settings_provider.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('SettingsNotifier initial state loads defaults', () {
    final state = container.read(settingsProvider);
    expect(state.cardStyle, CardStyle.modern);
    expect(state.isAutoSpeechEnabled, false);
  });

  test('setCardStyle updates state and persistence', () async {
    final notifier = container.read(settingsProvider.notifier);

    notifier.setCardStyle(CardStyle.classic);

    expect(container.read(settingsProvider).cardStyle, CardStyle.classic);
    expect(prefs.getInt('card_style'), CardStyle.classic.index);
  });

  test('toggleAutoSpeech updates state and persistence', () async {
    final notifier = container.read(settingsProvider.notifier);

    notifier.toggleAutoSpeech(true);

    expect(container.read(settingsProvider).isAutoSpeechEnabled, true);
    expect(prefs.getBool('auto_speech_enabled'), true);
  });

  test('togglePowerSaving updates state and persistence', () async {
    final notifier = container.read(settingsProvider.notifier);

    notifier.togglePowerSaving(true);

    expect(container.read(settingsProvider).isPowerSavingEnabled, true);
    expect(prefs.getBool('power_saving_enabled'), true);
  });
}
