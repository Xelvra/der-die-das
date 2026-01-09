import 'package:der_die_das/app_theme.dart';
import 'package:der_die_das/providers/stats_provider.dart';
import 'package:der_die_das/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:der_die_das/l10n/app_localizations.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  final FocusScopeNode _focusNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsProvider);
    final theme = Theme.of(context);
    final appTheme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowDown):
            DirectionalFocusIntent(TraversalDirection.down),
        SingleActivator(LogicalKeyboardKey.arrowUp):
            DirectionalFocusIntent(TraversalDirection.up),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.space): DoNothingIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) => Navigator.pop(context)),
          DoNothingIntent: DoNothingAction(),
        },
        child: FocusScope(
          node: _focusNode,
          autofocus: true,
          child: Container(
            decoration: AppThemes.getBackgroundDecoration(appTheme),
            child: Scaffold(
              backgroundColor: Colors
                  .transparent, // Important for background to show through
              appBar: AppBar(
                title: Text(l10n.statsTitle),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.refreshStats,
                    onPressed: () => ref.refresh(statsProvider),
                  )
                ],
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(12.0),
                  child: SizedBox(height: 12.0),
                ),
              ),
              body: statsAsync.when(
                data: (stats) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Hero Metrics (Streak)
                      _buildStreakCard(stats, theme, l10n),
                      const SizedBox(height: 20),

                      // 2. Global Progress
                      _buildProgressCard(stats, theme, l10n),
                      const SizedBox(height: 24),

                      // 3. Leaderboards Header
                      Text(
                        l10n.hallOfFame,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // 4. Tabs for Modes
                      DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              indicatorColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.5),
                              labelColor: theme.colorScheme.primary,
                              unselectedLabelColor: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              tabs: [
                                Tab(text: l10n.survival),
                                Tab(text: l10n.challenge),
                              ],
                            ),
                            SizedBox(
                              height: 300,
                              child: TabBarView(
                                children: [
                                  _buildHighScoresList(
                                      stats.survivalHighScores, theme, l10n,
                                      isSurvival: true),
                                  _buildHighScoresList(
                                      stats.challengeHighScores, theme, l10n,
                                      isSurvival: false),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(
      UserStats stats, ThemeData theme, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.local_fire_department,
                size: 48,
                color: theme.brightness == Brightness.dark
                    ? Colors.orangeAccent
                    : Colors.orange),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${stats.currentStreak} ${l10n.streakDays}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Text(
                    l10n.currentStreak,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
      UserStats stats, ThemeData theme, AppLocalizations l10n) {
    final percentage =
        stats.totalWords > 0 ? (stats.learnedWords / stats.totalWords) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.globalProgress,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(percentage * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l10n.learnedStats(stats.learnedWords, stats.totalWords),
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighScoresList(
      List<Map<String, dynamic>> scores, ThemeData theme, AppLocalizations l10n,
      {required bool isSurvival}) {
    if (scores.isEmpty) {
      return Center(child: Text(l10n.noScores));
    }

    return ListView.builder(
      itemCount: scores.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        final score = scores[index];
        final date = DateTime.parse(score['played_at'] as String);
        final formattedDate = DateFormat('d.M.yyyy HH:mm').format(date);

        Color? badgeColor;
        if (index == 0) {
          badgeColor =
              const Color(0xFFFFD700).withValues(alpha: 0.6); // Soft Gold
        } else if (index == 1) {
          badgeColor =
              const Color(0xFFC0C0C0).withValues(alpha: 0.6); // Soft Silver
        } else if (index == 2) {
          badgeColor =
              const Color(0xFFCD7F32).withValues(alpha: 0.6); // Soft Bronze
        } else {
          badgeColor = theme.colorScheme.onSurface.withValues(alpha: 0.05);
        }

        return ListTile(
          onTap: () {}, // Add empty onTap to make it focusable
          leading: CircleAvatar(
            backgroundColor: badgeColor,
            foregroundColor: theme.colorScheme.onSurface,
            child: Text('#${index + 1}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          title: Text(
            "${score['score']} ${l10n.points}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(formattedDate, style: theme.textTheme.bodySmall),
          trailing: isSurvival
              ? Text("${score['duration_seconds']}s",
                  style: theme.textTheme.bodySmall)
              : null,
        );
      },
    );
  }
}
