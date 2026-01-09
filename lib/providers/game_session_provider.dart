import 'dart:async';
import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/models/game_state.dart';
import 'package:der_die_das/models/word.dart';
import 'package:der_die_das/providers/database_providers.dart';
import 'package:der_die_das/providers/settings_provider.dart';
import 'package:der_die_das/providers/stats_provider.dart';
import 'package:der_die_das/services/game_timer_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSessionNotifier extends Notifier<GameState> {
  static const _kGameModeKey = 'selected_game_mode';
  static const _kSelectedLevelKey = 'selected_language_level';

  DateTime? _sessionStartTime;
  int _loadingOperationId = 0;

  @override
  GameState build() {
    // Initial load happens via a separate method called from UI or initialization service
    // to keep build() pure and sync.
    return const GameState();
  }

  Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_kGameModeKey) ?? 0;
    final levelIndex = prefs.getInt(_kSelectedLevelKey) ?? 0;

    final mode = (modeIndex >= 0 && modeIndex < GameMode.values.length)
        ? GameMode.values[modeIndex]
        : GameMode.a1;

    final level = (levelIndex >= 0 && levelIndex < GameMode.values.length)
        ? GameMode.values[levelIndex]
        : GameMode.a1;

    state = state.copyWith(selectedLevel: level);
    loadLevel(mode);
  }

  Future<void> loadLevel(GameMode mode) async {
    final currentOperationId = ++_loadingOperationId;

    final timerService = ref.read(gameTimerServiceProvider);
    timerService.cancel();

    double initialMaxTime = mode == GameMode.challenge ? 50.0 : 60.0;
    double initialRemaining =
        mode == GameMode.challenge ? 25.0 : initialMaxTime;

    state = state.copyWith(
      isLoading: true,
      gameMode: mode,
      selectedLevel: mode.isLevel ? mode : state.selectedLevel,
      remainingTime: initialRemaining,
      maxTime: initialMaxTime,
      score: 0,
      isGameOver: false,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      if (_loadingOperationId != currentOperationId) return;

      await prefs.setInt(_kGameModeKey, mode.index);
      if (mode.isLevel) {
        await prefs.setInt(_kSelectedLevelKey, mode.index);
      }

      final vocabRepo = ref.read(vocabularyRepositoryProvider);
      final progressRepo = ref.read(progressRepositoryProvider);

      List<Word> wordsToLearn = [];
      final List<String> levelsToLoad =
          (mode.isLevel ? mode : state.selectedLevel).associatedLevels;

      switch (mode) {
        case GameMode.reviewLearned:
          wordsToLearn = await progressRepo.getLearnedNouns();
          break;
        case GameMode.weakPoints:
          wordsToLearn = await progressRepo.getHardestNouns();
          break;
        case GameMode.survival:
        case GameMode.challenge:
        case GameMode.autoplay:
          wordsToLearn = await vocabRepo.getNounsForLevel(levelsToLoad);
          break;
        default:
          wordsToLearn = await progressRepo.getDueNouns(levelsToLoad);
          if (wordsToLearn.isEmpty) {
            wordsToLearn = await vocabRepo.getNounsForLevel(levelsToLoad);
          }
          break;
      }

      if (_loadingOperationId != currentOperationId) return;

      final shuffledWords = List<Word>.from(wordsToLearn)..shuffle();

      state = state.copyWith(
        words: shuffledWords,
        isLoading: false,
        currentIndex: 0,
      );

      _sessionStartTime = DateTime.now();

      if (mode.hasTimer) {
        _startTimer();
      }
    } catch (e) {
      if (_loadingOperationId == currentOperationId) {
        state = state.copyWith(isLoading: false, words: []);
      }
    }
  }

  void _startTimer() {
    final timerService = ref.read(gameTimerServiceProvider);
    final settings = ref.read(settingsProvider);

    timerService.start(state.remainingTime, state.maxTime, (newTime) {
      if (newTime <= 0) {
        state = state.copyWith(isGameOver: true, remainingTime: 0.0);
        _saveScore();
      } else {
        state = state.copyWith(remainingTime: newTime);
      }
    }, fastMode: settings.isPowerSavingEnabled);
  }

  void pauseTimer() {
    ref.read(gameTimerServiceProvider).pause();
  }

  void resumeTimer() {
    if (state.isGameOver || !state.gameMode.hasTimer) return;

    final timerService = ref.read(gameTimerServiceProvider);
    final settings = ref.read(settingsProvider);

    timerService.resume(state.remainingTime, state.maxTime, (newTime) {
      if (newTime <= 0) {
        state = state.copyWith(isGameOver: true, remainingTime: 0.0);
        _saveScore();
      } else {
        state = state.copyWith(remainingTime: newTime);
      }
    }, fastMode: settings.isPowerSavingEnabled);
  }

  // Necessary for lifecycle changes if we need to sync precise time before pausing
  void updateRemainingTime() {
    // With the new TimerService, the state is updated on every tick.
    // If we need simpler sync, we rely on the last state update.
    // This method is kept for compatibility but might be redundant if ticks are frequent.
  }

  Future<void> submitAnswer(String selectedArticle) async {
    final word = state.currentWord;
    if (word == null) return;

    final isCorrect =
        word.article.toLowerCase() == selectedArticle.toLowerCase();

    if (state.gameMode == GameMode.weakPoints && !isCorrect) return;
    if (state.gameMode == GameMode.autoplay) return;

    // Optimistic update prevention: if the game is already over or reset, don't proceed
    if (state.isGameOver) return;

    await ref
        .read(progressRepositoryProvider)
        .updateWordStatus(word.id, isCorrect);
    ref.invalidate(statsProvider);

    // Check again if game state is still valid
    if (state.isGameOver) return;

    if (state.gameMode == GameMode.survival) {
      _handleSurvivalAnswer(isCorrect);
    } else if (state.gameMode == GameMode.challenge) {
      _handleChallengeAnswer(isCorrect);
    }
  }

  void _handleSurvivalAnswer(bool isCorrect) {
    if (state.isGameOver) return;

    double newTime = state.remainingTime;
    if (isCorrect) {
      newTime += 5;
      if (newTime > state.maxTime) newTime = state.maxTime;
      state = state.copyWith(score: state.score + 1, remainingTime: newTime);
    } else {
      newTime -= 3;
      if (newTime < 0) newTime = 0;
      state = state.copyWith(remainingTime: newTime);
    }

    // Restart timer with new time
    _startTimer();
  }

  void _handleChallengeAnswer(bool isCorrect) {
    if (state.isGameOver) return;

    double newPoints = state.remainingTime;
    if (isCorrect) {
      newPoints += 5;
      if (newPoints > state.maxTime) newPoints = state.maxTime;
      state = state.copyWith(score: state.score + 1, remainingTime: newPoints);
    } else {
      newPoints -= 5;
      if (newPoints < 0) newPoints = 0;
      state = state.copyWith(remainingTime: newPoints);
    }

    if (newPoints <= 0) {
      state = state.copyWith(isGameOver: true, remainingTime: 0.0);
      _saveScore();
    } else {
      // Just update state, NO TIMER for challenge mode
      state = state.copyWith(remainingTime: newPoints);
    }
  }

  Future<void> _saveScore() async {
    if (!state.gameMode.hasScoring) return;
    if (state.score <= 0) return;

    final modeStr = state.gameMode.dbIdentifier;

    int duration = 0;
    if (_sessionStartTime != null) {
      duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
    } else {
      duration = (state.maxTime - state.remainingTime).round().clamp(0, 9999);
    }

    await ref
        .read(progressRepositoryProvider)
        .saveGameResult(modeStr, state.score, duration);
  }

  void nextWord() {
    if (state.words.isEmpty) {
      loadLevel(state.gameMode);
      return;
    }

    if (state.currentIndex >= state.words.length - 1) {
      if (state.gameMode.hasScoring) {
        final shuffledWords = List<Word>.from(state.words)..shuffle();
        state = state.copyWith(
          words: shuffledWords,
          currentIndex: 0,
        );
      } else {
        loadLevel(state.gameMode);
      }
    } else {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void restartGame() {
    loadLevel(state.gameMode);
  }

  void endGameEarly() {
    if (state.isGameOver || state.isLoading) return;
    state = state.copyWith(isGameOver: true);
    ref.read(gameTimerServiceProvider).cancel();
    _saveScore();
  }
}

final gameSessionProvider =
    NotifierProvider<GameSessionNotifier, GameState>(GameSessionNotifier.new);
