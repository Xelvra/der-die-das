import 'package:flutter_test/flutter_test.dart';
import 'package:der_die_das/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:der_die_das/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test - starts and shows initialization',
      (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    // We must wrap DerDieDasApp in a ProviderScope and override the sharedPreferencesProvider
    // to provide a mock SharedPreferences instance.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const DerDieDasApp(),
      ),
    );

    // Verify that the app starts (checking for DerDieDasApp widget presence)
    // We use pump() instead of pumpAndSettle() because LoadingScreen has an infinite animation
    // and initialization logic might not complete in this basic test environment without extensive mocks.
    await tester.pump();

    expect(find.byType(DerDieDasApp), findsOneWidget);
  });
}
