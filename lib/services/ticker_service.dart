import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract interface for a timer/ticker to allow mocking in tests.
abstract class TickerService {
  Stream<int> tick({required int ticks, required Duration interval});
}

class TickerServiceImpl implements TickerService {
  const TickerServiceImpl();

  @override
  Stream<int> tick({required int ticks, required Duration interval}) {
    return Stream.periodic(interval, (x) => ticks - x - 1).take(ticks);
  }
}

/// A simple periodic timer wrapper that allows checking 'now' and cancelling.
/// This is more suitable for the game loop than a pure Stream if we need pause/resume.
class GameTimer {
  Timer? _timer;

  void startPeriodic(Duration interval, void Function(Timer) callback) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, callback);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isActive => _timer?.isActive ?? false;
}

final timerServiceProvider = Provider<GameTimer>((ref) => GameTimer());
