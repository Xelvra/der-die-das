import 'dart:async';
import 'package:der_die_das/providers/database_providers.dart';
import 'package:der_die_das/repositories/progress_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStats {
  final int totalWords;
  final int learnedWords;
  final int currentStreak;
  final List<Map<String, dynamic>> survivalHighScores;
  final List<Map<String, dynamic>> challengeHighScores;
  final Map<String, double> levelProgress;

  const UserStats({
    this.totalWords = 0,
    this.learnedWords = 0,
    this.currentStreak = 0,
    this.survivalHighScores = const [],
    this.challengeHighScores = const [],
    this.levelProgress = const {},
  });
}

class StatsNotifier extends AsyncNotifier<UserStats> {
  @override
  FutureOr<UserStats> build() async {
    return _fetchStats();
  }

  Future<UserStats> _fetchStats() async {
    final vocabRepo = ref.read(vocabularyRepositoryProvider);
    final progressRepo = ref.read(progressRepositoryProvider);

    // 1. Basic Counts
    final total = await vocabRepo.getTotalWordCount();

    // Learned words (reps > 0)
    final learnedCount = await progressRepo.getLearnedWordsCount();

    // 2. Streak
    final streak = await progressRepo.getCurrentStreak();

    // 3. High Scores
    final survivalScores =
        await progressRepo.getTopScores(ProgressRepository.modeSurvival);
    final challengeScores =
        await progressRepo.getTopScores(ProgressRepository.modeChallenge);

    // 4. Level Progress (Approximation)
    // This requires joining tables. For now, we can calculate global progress.
    final levelProgress = <String, double>{};
    // Placeholder: In a real scenario, we would query: SELECT noun.level, COUNT(*) FROM word_status JOIN nouns ON ...

    return UserStats(
      totalWords: total,
      learnedWords: learnedCount,
      currentStreak: streak,
      survivalHighScores: survivalScores,
      challengeHighScores: challengeScores,
      levelProgress: levelProgress,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, UserStats>(StatsNotifier.new);
