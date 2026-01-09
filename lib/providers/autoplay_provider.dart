import 'dart:async';
import 'package:der_die_das/providers/game_session_provider.dart';
import 'package:der_die_das/providers/settings_provider.dart';
import 'package:der_die_das/providers/tts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AutoplayState {
  stopped,
  playing,
  speaking, // TTS is active
  waiting, // Pause between word/answer
}

class AutoplayNotifier extends Notifier<AutoplayState> {
  Timer? _loopTimer;
  final _swipeController = StreamController<String>.broadcast();

  Stream<String> get swipeRequestStream => _swipeController.stream;

  @override
  AutoplayState build() {
    ref.onDispose(() {
      _cancelTimer();
      _swipeController.close();
    });
    return AutoplayState.stopped;
  }

  void toggle() {
    if (state == AutoplayState.stopped) {
      play();
    } else {
      stop();
    }
  }

  void play() {
    if (state != AutoplayState.stopped) return;
    state = AutoplayState.playing;
    _runLoop();
  }

  void stop() {
    _cancelTimer();
    state = AutoplayState.stopped;
  }

  void _cancelTimer() {
    _loopTimer?.cancel();
    _loopTimer = null;
  }

  Future<void> _runLoop() async {
    if (state == AutoplayState.stopped) return;

    final gameState = ref.read(gameSessionProvider);
    if (gameState.isGameOver || gameState.currentWord == null) {
      stop();
      return;
    }

    // Step 1: Delay before speaking (simulates waiting for card animation)
    _loopTimer = Timer(const Duration(milliseconds: 800), () async {
      if (state == AutoplayState.stopped) return;

      final settings = ref.read(settingsProvider);

      // Step 2: Speak if enabled
      if (settings.isAutoSpeechEnabled) {
        state = AutoplayState.speaking;
        final word = gameState.currentWord!;
        await ref
            .read(ttsServiceProvider)
            .speak('${word.article} ${word.word}');
        // Wait a bit after speech
        await Future<void>.delayed(const Duration(milliseconds: 800));
      } else {
        // If no speech, just wait longer
        state = AutoplayState.waiting;
        await Future<void>.delayed(const Duration(milliseconds: 1200));
      }

      if (state == AutoplayState.stopped) return;

      // Step 3: Trigger "Swipe"
      state = AutoplayState.waiting;

      final word = gameState.currentWord!;
      // Trigger UI animation via stream
      _swipeController.add(word.article);

      // Wait for animation (fixed duration)
      await Future<void>.delayed(const Duration(milliseconds: 400));

      if (state != AutoplayState.stopped) {
        // Logic update
        await ref.read(gameSessionProvider.notifier).submitAnswer(word.article);
        ref.read(gameSessionProvider.notifier).nextWord();

        // Restart loop
        _runLoop();
      }
    });
  }
}

final autoplayProvider =
    NotifierProvider<AutoplayNotifier, AutoplayState>(AutoplayNotifier.new);
