import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:der_die_das/models/word.dart';
import 'package:der_die_das/models/game_mode.dart';

part 'game_state.freezed.dart';

@freezed
abstract class GameState with _$GameState {
  const GameState._(); // Added for custom getters

  const factory GameState({
    @Default([]) List<Word> words,
    @Default(0) int currentIndex,
    @Default(true) bool isLoading,
    @Default(GameMode.a1) GameMode gameMode,
    @Default(GameMode.a1) GameMode selectedLevel,
    @Default(60.0) double remainingTime,
    @Default(60.0) double maxTime,
    @Default(0) int score,
    @Default(false) bool isGameOver,
  }) = _GameState;

  Word? get currentWord => words.isNotEmpty && currentIndex < words.length
      ? words[currentIndex]
      : null;
  bool get isFinished => words.isEmpty ? false : currentIndex >= words.length;
}
