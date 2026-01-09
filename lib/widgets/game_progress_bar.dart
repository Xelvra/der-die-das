import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:der_die_das/providers/game_session_provider.dart';
import 'package:der_die_das/services/game_timer_service.dart';
import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/widgets/custom_progress_bar.dart';

class GameProgressBar extends ConsumerWidget {
  const GameProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameMode = ref.watch(gameSessionProvider.select((s) => s.gameMode));
    final maxTime = ref.watch(gameSessionProvider.select((s) => s.maxTime));

    final bool showProgressBar = gameMode == GameMode.survival ||
        gameMode == GameMode.challenge ||
        gameMode == GameMode.reviewLearned ||
        gameMode == GameMode.weakPoints ||
        gameMode == GameMode.autoplay ||
        gameMode.isLevel;

    if (!showProgressBar) {
      return const SizedBox(height: 12);
    }

    if (gameMode == GameMode.survival) {
      return StreamBuilder<double>(
        stream: ref.watch(gameTimerServiceProvider).timeStream,
        initialData: maxTime,
        builder: (context, snapshot) {
          final remaining = snapshot.data ?? maxTime;
          final value = (remaining / maxTime).clamp(0.0, 1.0);

          Color barColor;
          if (remaining > 10) {
            barColor = Colors.green;
          } else if (remaining > 5) {
            barColor = Colors.orange;
          } else {
            barColor = Colors.red;
          }

          return CustomProgressBar(
            value: value,
            color: barColor,
          );
        },
      );
    }

    if (gameMode == GameMode.challenge) {
      final remaining =
          ref.watch(gameSessionProvider.select((s) => s.remainingTime));
      final value = (remaining / maxTime).clamp(0.0, 1.0);

      Color barColor =
          value < 0.20 ? Colors.red : Theme.of(context).colorScheme.primary;

      return CustomProgressBar(
        value: value,
        color: barColor,
      );
    }

    final total = ref.watch(gameSessionProvider.select((s) => s.words.length));
    final currentIndex =
        ref.watch(gameSessionProvider.select((s) => s.currentIndex));

    if (total == 0) return const SizedBox.shrink();
    final progressValue = currentIndex / total;

    return CustomProgressBar(
      value: progressValue,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
