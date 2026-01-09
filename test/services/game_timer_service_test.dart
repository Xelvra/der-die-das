import 'package:der_die_das/services/game_timer_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameTimerService timerService;

  setUp(() {
    timerService = GameTimerService();
  });

  tearDown(() {
    timerService.dispose();
  });

  test('Timer emits values and counts down', () async {
    // Start 1 second timer, tick every 100ms (0.1s)
    // We expect roughly 10 ticks.

    int ticks = 0;
    timerService.start(1.0, 1.0, (val) {
      ticks++;
    });

    // Wait for timer to finish (1s + buffer)
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    // Should be at least 10 ticks (1.0 -> 0.9 -> ... -> 0.0)
    expect(ticks, greaterThanOrEqualTo(10));
  });

  test('Timer respects pause and resume', () async {
    double lastValue = 5.0;

    timerService.start(5.0, 5.0, (val) {
      lastValue = val;
    });

    // Run for 200ms
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final valueBeforePause = lastValue;
    expect(valueBeforePause, lessThan(5.0));

    // PAUSE
    timerService.pause();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Value should not change during pause
    expect(lastValue, valueBeforePause);

    // RESUME
    timerService.resume(lastValue, 5.0, (val) {
      lastValue = val;
    });

    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(lastValue, lessThan(valueBeforePause));
  });

  test('Timer stops exactly at 0', () async {
    double? finalValue;
    timerService.start(0.2, 1.0, (val) {
      finalValue = val;
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(finalValue, 0.0);
  });
}
