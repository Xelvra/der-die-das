import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameTimerService {
  Timer? _timer;
  final _timeController = StreamController<double>.broadcast();

  Stream<double> get timeStream => _timeController.stream;

  void start(double initialTime, double maxTime, void Function(double) onTick,
      {bool fastMode = false}) {
    cancel();

    double remaining = initialTime;
    // 100ms standard, 500ms power saving (handled by logic outside or passed here)
    // For smooth UI, we usually want 100ms or even 16ms, but let's stick to logic tick.
    final interval = fastMode
        ? const Duration(milliseconds: 500)
        : const Duration(milliseconds: 100);
    final decrement = interval.inMilliseconds / 1000.0;

    _timer = Timer.periodic(interval, (timer) {
      remaining -= decrement;
      if (remaining <= 0) {
        remaining = 0;
        cancel();
      }
      onTick(remaining);
      _timeController.add(remaining);
    });
  }

  void pause() {
    _timer?.cancel();
  }

  void resume(
      double currentRemaining, double maxTime, void Function(double) onTick,
      {bool fastMode = false}) {
    start(currentRemaining, maxTime, onTick, fastMode: fastMode);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
    _timeController.close();
  }
}

final gameTimerServiceProvider = Provider<GameTimerService>((ref) {
  final service = GameTimerService();
  ref.onDispose(() => service.dispose());
  return service;
});
