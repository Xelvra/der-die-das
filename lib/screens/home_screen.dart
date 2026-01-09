import 'dart:async';

import 'package:der_die_das/app_drawer.dart';
import 'package:der_die_das/app_theme.dart';
import 'package:der_die_das/l10n/app_localizations.dart';
import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/providers/autoplay_provider.dart';
import 'package:der_die_das/providers/game_session_provider.dart';
import 'package:der_die_das/providers/theme_provider.dart';
import 'package:der_die_das/providers/settings_provider.dart';
import 'package:der_die_das/providers/window_provider.dart';
import 'package:der_die_das/widgets/swipeable_card_deck.dart';
import 'package:der_die_das/services/stt_service.dart';
import 'package:der_die_das/widgets/adaptive_card_layout.dart';
import 'package:der_die_das/widgets/game_progress_bar.dart';
import 'package:der_die_das/widgets/level_complete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final bool isDesktop =
    !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // --- Constants ---
  static const Duration _kAnswerDisplayDuration = Duration(milliseconds: 1000);

  // --- UI State ---
  bool _showAnswer = false;
  bool _isProcessingAnswer = false;
  bool _isListening = false;
  bool _answeredViaVoice = false;

  // Autoplay Stream Subscription
  StreamSubscription<String>? _swipeSubscription;

  // Controllers & Keys
  final SwipeDeckController _deckController = SwipeDeckController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  late SttService _sttService;

  @override
  void initState() {
    super.initState();
    _sttService = ref.read(sttServiceProvider);

    // Ensure window manager logic is active
    ref.read(windowProvider);

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sttService.setStatusListener((isListening) {
        if (mounted) {
          setState(() => _isListening = isListening);
        }
      });
      _focusNode.requestFocus();

      // Subscribe to Autoplay Swipe Requests
      _swipeSubscription = ref
          .read(autoplayProvider.notifier)
          .swipeRequestStream
          .listen((article) {
        if (mounted) {
          _deckController.swipe(article);
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final bool isPaused = state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden;

    if (isPaused) {
      // Stop autoplay on pause
      ref.read(autoplayProvider.notifier).stop();

      final gameMode = ref.read(gameSessionProvider).gameMode;
      if (gameMode == GameMode.survival) {
        ref.read(gameSessionProvider.notifier).pauseTimer();
      }
    } else if (state == AppLifecycleState.resumed) {
      final gameMode = ref.read(gameSessionProvider).gameMode;
      if (gameMode == GameMode.survival) {
        ref.read(gameSessionProvider.notifier).resumeTimer();
      }
    }
  }

  Future<void> _startListening() async {
    if (isDesktop || _showAnswer) return;

    await _sttService.listen(
      onResult: (article) {
        if (!_showAnswer && mounted) {
          _processAnswer(article, fromVoice: true);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _sttService.stop();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  @override
  void dispose() {
    _swipeSubscription?.cancel();
    _sttService.stop();
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleRestart() {
    setState(() {
      _showAnswer = false;
      _isProcessingAnswer = false;
      _answeredViaVoice = false;
    });
    ref.read(autoplayProvider.notifier).stop();
    ref.read(gameSessionProvider.notifier).restartGame();
  }

  void _toggleAutoplay() {
    ref.read(autoplayProvider.notifier).toggle();
  }

  Future<void> _processAnswer(String selectedArticle,
      {bool fromVoice = false}) async {
    final gameState = ref.read(gameSessionProvider);
    if (_showAnswer || _isProcessingAnswer || gameState.isGameOver) return;

    _isProcessingAnswer = true;
    _stopListening();

    final currentWord = gameState.currentWord;
    if (currentWord == null) return;

    setState(() {
      _answeredViaVoice = fromVoice;
    });

    final isCorrect =
        currentWord.article.toLowerCase() == selectedArticle.toLowerCase();
    final gameMode = gameState.gameMode;

    final bool shouldShake = !isCorrect &&
        gameMode != GameMode.survival &&
        gameMode != GameMode.challenge;

    if (shouldShake) {
      await _deckController.shake();
      if (gameMode == GameMode.weakPoints) {
        _deckController.returnToCenter();
      }
    }

    final settings = ref.read(settingsProvider);
    final hapticsAllowed =
        settings.isHapticsEnabled && !settings.isPowerSavingEnabled;
    if (!isCorrect && !isDesktop && hapticsAllowed && shouldShake) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 50);
      }
    }

    // Logic delegated to Notifier
    ref.read(gameSessionProvider.notifier).submitAnswer(selectedArticle);

    if (gameMode == GameMode.weakPoints && !isCorrect) {
      _isProcessingAnswer = false;
      return;
    }

    if (gameMode == GameMode.autoplay) {
      ref.read(autoplayProvider.notifier).stop();
      _deckController.swipe(selectedArticle).then((_) {
        _goToNextWord();
      });
      return;
    }

    if (gameMode == GameMode.survival || gameMode == GameMode.challenge) {
      _deckController.swipe(selectedArticle).then((_) {
        _goToNextWord();
      });
      return;
    }

    setState(() {
      _showAnswer = true;
    });

    Future.delayed(_kAnswerDisplayDuration, () {
      if (!mounted) return;
      _deckController.swipe(currentWord.article).then((_) {
        _goToNextWord();
      });
    });
  }

  void _goToNextWord() {
    if (!mounted) return;

    final state = ref.read(gameSessionProvider);
    final gameMode = state.gameMode;
    final isLastCard = state.currentIndex >= state.words.length - 1;
    final shouldCelebrate = isLastCard && gameMode.isLevel;

    if (shouldCelebrate) {
      _showLevelCompleteDialog();
    } else {
      _performTransition();
    }
  }

  void _performTransition() {
    final bool wasVoiceChain = _answeredViaVoice;

    ref.read(gameSessionProvider.notifier).nextWord();

    setState(() {
      _showAnswer = false;
      _isProcessingAnswer = false;
      _answeredViaVoice = false;
    });

    if (wasVoiceChain) {
      // Logic for voice chain could be added here
    }
  }

  void _showLevelCompleteDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Level Complete',
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: LevelCompleteDialog(
            onContinue: () => _performTransition(),
          ),
        );
      },
    );
  }

  String _getModeTitle(GameMode mode, AppLocalizations l10n) {
    switch (mode) {
      case GameMode.reviewLearned:
        return l10n.reviewLearned;
      case GameMode.survival:
        return l10n.survival;
      case GameMode.challenge:
        return l10n.challenge;
      case GameMode.weakPoints:
        return l10n.weakPoints;
      case GameMode.autoplay:
        return l10n.autoplay;
      case GameMode.a1:
      case GameMode.a2:
      case GameMode.b1:
      case GameMode.b2:
      case GameMode.c1:
      case GameMode.c2:
        if (mode == GameMode.a1) return 'A1';
        return '(A1 – ${mode.name.toUpperCase()})';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = ref.watch(themeProvider);

    ref.listen(settingsProvider.select((s) => s.isPowerSavingEnabled),
        (previous, next) {
      if (previous != next) {
        final gameMode = ref.read(gameSessionProvider).gameMode;
        if (gameMode == GameMode.survival) {
          ref.read(gameSessionProvider.notifier).resumeTimer();
        }
      }
    });

    ref.listen(settingsProvider.select((s) => s.isSpeechRecognitionEnabled),
        (previous, next) {
      if (next == false) {
        _stopListening();
      }
    });

    ref.listen(gameSessionProvider.select((s) => s.gameMode), (previous, next) {
      if (previous != next) {
        ref.read(autoplayProvider.notifier).stop();
        if (mounted) {
          setState(() {
            _isProcessingAnswer = false;
            _showAnswer = false;
            _answeredViaVoice = false;
          });
        }
      }
    });

    final autoplayState = ref.watch(autoplayProvider);
    final isAutoplaying = autoplayState != AutoplayState.stopped;

    final gameMode = ref.watch(gameSessionProvider.select((s) => s.gameMode));
    final selectedLevel =
        ref.watch(gameSessionProvider.select((s) => s.selectedLevel));
    final isGameOver =
        ref.watch(gameSessionProvider.select((s) => s.isGameOver));
    final isLoading = ref.watch(gameSessionProvider.select((s) => s.isLoading));
    final isEmpty =
        ref.watch(gameSessionProvider.select((s) => s.words.isEmpty));
    final score = ref.watch(gameSessionProvider.select((s) => s.score));

    final words = ref.watch(gameSessionProvider.select((s) => s.words));
    final currentIndex =
        ref.watch(gameSessionProvider.select((s) => s.currentIndex));

    final modeTitle = _getModeTitle(gameMode, l10n);
    final isTrainingMode =
        gameMode == GameMode.survival || gameMode == GameMode.challenge;

    final screenHeight = MediaQuery.of(context).size.height;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _processAnswer('die'),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _processAnswer('der'),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _processAnswer('das'),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _deckController.setHintVisible(true),
        const SingleActivator(LogicalKeyboardKey.keyW): () =>
            _processAnswer('das'),
        const SingleActivator(LogicalKeyboardKey.keyA): () =>
            _processAnswer('die'),
        const SingleActivator(LogicalKeyboardKey.keyD): () =>
            _processAnswer('der'),
        const SingleActivator(LogicalKeyboardKey.keyS): () =>
            _deckController.setHintVisible(true),
        const SingleActivator(LogicalKeyboardKey.space): () =>
            _deckController.setHintVisible(true),
        const SingleActivator(LogicalKeyboardKey.keyR): () => _handleRestart(),
        const SingleActivator(LogicalKeyboardKey.keyM): () {
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Navigator.pop(context);
          } else {
            _scaffoldKey.currentState?.openDrawer();
          }
        },
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: Stack(
          children: [
            Container(decoration: AppThemes.getBackgroundDecoration(appTheme)),
            Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(modeTitle),
                centerTitle: true,
                actions: [
                  if (!isGameOver &&
                      !isLoading &&
                      (gameMode == GameMode.survival ||
                          gameMode == GameMode.challenge))
                    IconButton(
                      icon: const Icon(Icons.stop_circle_outlined),
                      onPressed: () =>
                          ref.read(gameSessionProvider.notifier).endGameEarly(),
                      tooltip: l10n.endGame,
                    ),
                ],
                bottom: screenHeight > 50
                    ? const PreferredSize(
                        preferredSize: Size.fromHeight(12.0),
                        child: RepaintBoundary(
                          child: GameProgressBar(),
                        ),
                      )
                    : null,
              ),
              drawer: AppDrawer(
                currentMode: gameMode,
                selectedLevel: selectedLevel,
                onModeChanged: (mode) {
                  ref.read(gameSessionProvider.notifier).loadLevel(mode);
                },
              ),
              body: isGameOver
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              gameMode == GameMode.survival
                                  ? Icons.timer_off_outlined
                                  : Icons.emoji_events_outlined,
                              size: 80,
                              color: Colors.red),
                          const SizedBox(height: 20),
                          Text(
                            l10n.gameOver,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.survivalScore(score),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 30),
                          FilledButton.icon(
                            onPressed: () {
                              _handleRestart();
                            },
                            icon: const Icon(Icons.replay),
                            label: Text(l10n.tryAgain),
                          ),
                        ],
                      ),
                    )
                  : isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(l10n.noWordsFound,
                                      style: const TextStyle(fontSize: 18)),
                                  const SizedBox(height: 20),
                                  FilledButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(gameSessionProvider.notifier)
                                          .loadLevel(selectedLevel);
                                    },
                                    icon: const Icon(Icons.arrow_back),
                                    label: Text(
                                        '${l10n.tryAgain} (${selectedLevel.name.toUpperCase()})'),
                                  ),
                                ],
                              ),
                            )
                          : AdaptiveCardLayout(
                              card: RepaintBoundary(
                                child: LayoutBuilder(
                                    builder: (context, cardConstraints) {
                                  return SwipeableCardDeck(
                                    words: words,
                                    currentIndex: currentIndex,
                                    isTrainingMode: isTrainingMode,
                                    gameMode: gameMode,
                                    appTheme: appTheme,
                                    width: cardConstraints.maxWidth,
                                    height: cardConstraints.maxHeight,
                                    onSwipe: _processAnswer,
                                    showAnswer: _showAnswer,
                                    controller: _deckController,
                                    isListening: _isListening,
                                    onMicTap: _startListening,
                                    answeredViaVoice: _answeredViaVoice,
                                  );
                                }),
                              ),
                              bottomContent: GestureDetector(
                                onTap: () {
                                  if (!_focusNode.hasFocus) {
                                    _focusNode.requestFocus();
                                  }
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Center(
                                  child: RepaintBoundary(
                                    child: gameMode == GameMode.autoplay
                                        ? _buildPlayerControls(
                                            appTheme, isAutoplaying)
                                        : _buildSwipeHints(appTheme),
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerControls(AppTheme appTheme, bool isAutoplaying) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                iconSize: 56,
                color: theme.colorScheme.error,
                tooltip: 'STOP',
                onPressed: () {
                  ref.read(autoplayProvider.notifier).stop();
                  final currentLevel =
                      ref.read(gameSessionProvider).selectedLevel;
                  ref
                      .read(gameSessionProvider.notifier)
                      .loadLevel(currentLevel);
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(isAutoplaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill),
                iconSize: 56,
                color: color,
                onPressed: () => _toggleAutoplay(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeHints(AppTheme appTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHint('die', Icons.swipe_left_outlined, appTheme),
        _buildHint('das', Icons.swipe_up_outlined, appTheme),
        _buildHint('der', Icons.swipe_right_outlined, appTheme),
      ],
    );
  }

  Widget _buildHint(String article, IconData icon, AppTheme appTheme) {
    final color = AppThemes.getArticleColor(appTheme, article);
    return InkWell(
      onTap: () => _processAnswer(article),
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 4),
            Text(
              article.toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
