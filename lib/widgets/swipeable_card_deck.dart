import 'dart:math';
import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/models/word.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import 'word_card.dart';

/// Controller to trigger swipe actions programmatically from parent
class SwipeDeckController {
  _SwipeableCardDeckState? _state;

  void _attach(_SwipeableCardDeckState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  /// Triggers the swipe animation programmatically.
  /// Returns a future that completes when the animation is done.
  Future<void> swipe(String direction) async {
    if (_state != null) {
      return _state!._programmaticSwipe(direction);
    }
  }

  /// Sets whether the hint (answer) is visible on the current card.
  void setHintVisible(bool visible) {
    if (_state != null) {
      _state!._setHintVisible(visible);
    }
  }

  /// Triggers a shake animation to indicate an error.
  Future<void> shake() async {
    if (_state != null) {
      await _state!._shake();
    }
  }

  /// Returns the card to the center position programmatically.
  Future<void> returnToCenter() async {
    if (_state != null) {
      await _state!._returnToCenter();
    }
  }
}

class SwipeableCardDeck extends ConsumerStatefulWidget {
  final List<Word> words;
  final int currentIndex;
  final bool isTrainingMode;
  final GameMode gameMode;
  final AppTheme appTheme;
  final double width;
  final double height;
  final bool showAnswer;
  final SwipeDeckController? controller;
  final bool isListening;
  final VoidCallback? onMicTap;
  final bool answeredViaVoice;

  /// Callback when a card is swiped.
  /// [direction] is 'der', 'die', or 'das'.
  final void Function(String direction) onSwipe;

  const SwipeableCardDeck({
    super.key,
    required this.words,
    required this.currentIndex,
    required this.isTrainingMode,
    required this.gameMode,
    required this.appTheme,
    required this.width,
    required this.height,
    required this.onSwipe,
    this.showAnswer = false,
    this.controller,
    this.isListening = false,
    this.onMicTap,
    this.answeredViaVoice = false,
  });

  @override
  ConsumerState<SwipeableCardDeck> createState() => _SwipeableCardDeckState();
}

class _SwipeableCardDeckState extends ConsumerState<SwipeableCardDeck>
    with TickerProviderStateMixin {
  // --- Constants ---
  static const double _kSwipeThreshold = 20.0;
  static const double _kHintThreshold = 20.0;

  // --- Animation Controllers ---
  late AnimationController _animationController;
  late AnimationController _deckAnimationController;
  late AnimationController _shakeController;

  // --- State ---
  final ValueNotifier<Offset> _positionNotifier =
      ValueNotifier<Offset>(Offset.zero);
  bool _isDragging = false;
  late Animation<Offset> _swipeAnimation;
  bool _showHint = false;
  String?
      _lockedHighlightArticle; // Locks color after swipe release until reset

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.addListener(() {
      if (_animationController.isAnimating) {
        _positionNotifier.value = _swipeAnimation.value;
      }
    });

    _deckAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _deckAnimationController.addListener(() {
      setState(() {});
    });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(SwipeableCardDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }

    // If index changed (next word) OR game mode changed, reset position and state
    if (widget.currentIndex != oldWidget.currentIndex ||
        widget.gameMode != oldWidget.gameMode) {
      _resetState();
    }
  }

  void _resetState() {
    // 1. Stop all active animations immediately to prevent "ghost" movements
    _animationController.stop();
    _animationController.reset();

    _shakeController.stop();
    _shakeController.reset();

    // 2. Reset logic flags
    _isDragging = false;
    _positionNotifier.value = Offset.zero;
    _showHint = false;
    _lockedHighlightArticle = null;

    // 3. Play deck entry animation (visual feedback for reset)
    _deckAnimationController.forward(from: 0.0).then((_) {
      _deckAnimationController.reset();
    });
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _animationController.dispose();
    _deckAnimationController.dispose();
    _shakeController.dispose();
    _positionNotifier.dispose();
    super.dispose();
  }

  // --- Logic ---

  void _setHintVisible(bool visible) {
    if (!mounted || widget.showAnswer) return;
    // No hints in training (survival/challenge) or weakpoints
    if (widget.isTrainingMode || widget.gameMode == GameMode.weakPoints) return;

    setState(() {
      _showHint = visible;
    });
  }

  Future<void> _programmaticSwipe(String direction) {
    if (!mounted) return Future.value();
    return _animateCardAway(direction);
  }

  Future<void> _animateCardAway(String direction) {
    final screenSize = MediaQuery.of(context).size;
    Offset endPosition;

    if (direction.toLowerCase() == 'der') {
      endPosition = Offset(screenSize.width, _positionNotifier.value.dy);
    } else if (direction.toLowerCase() == 'die') {
      endPosition = Offset(-screenSize.width, _positionNotifier.value.dy);
    } else {
      // das
      endPosition = Offset(_positionNotifier.value.dx, -screenSize.height);
    }

    _animationController.reset();
    _swipeAnimation =
        Tween<Offset>(begin: _positionNotifier.value, end: endPosition).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    return _animationController.forward();
  }

  void _processSwipeEnd(DragEndDetails details) {
    if (widget.showAnswer) return; // Locked

    final pos = _positionNotifier.value;
    String? swipeDirection;
    if (pos.dx > _kSwipeThreshold && pos.dx.abs() > pos.dy.abs()) {
      swipeDirection = 'der';
    } else if (pos.dx < -_kSwipeThreshold && pos.dx.abs() > pos.dy.abs()) {
      swipeDirection = 'die';
    } else if (pos.dy < -_kSwipeThreshold && pos.dy.abs() > pos.dx.abs()) {
      swipeDirection = 'das';
    }

    _isDragging = false;

    if (swipeDirection != null) {
      _lockedHighlightArticle = swipeDirection; // Lock color
      widget.onSwipe(swipeDirection);
    } else {
      // Snap back
      _animationController.reset();
      _swipeAnimation = Tween<Offset>(begin: pos, end: Offset.zero).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutBack),
      );
      _animationController.forward();
    }
  }

  Future<void> _shake() async {
    _shakeController.reset();
    return _shakeController.forward();
  }

  Future<void> _returnToCenter() async {
    _lockedHighlightArticle = null;
    _animationController.reset();
    _swipeAnimation =
        Tween<Offset>(begin: _positionNotifier.value, end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    return _animationController.forward();
  }

  Color? _getCardBackgroundColor(String? currentArticle, Offset pos,
      {bool isInteractive = true}) {
    final cardColor = Theme.of(context).cardColor;

    // Priority: If answer is shown, let WordCard handle the correct coloring.
    // Ignore locked highlights to prevent color mixing.
    if (widget.showAnswer) return cardColor;

    Color? hintColor;

    // 1. Locked Highlight (During Shake/Error phase) - ONLY for top card (interactive)
    if (isInteractive && _lockedHighlightArticle != null) {
      hintColor =
          AppThemes.getArticleColor(widget.appTheme, _lockedHighlightArticle!);
    }
    // 2. Dragging Interaction
    else if (isInteractive && _isDragging) {
      if (pos.dx > _kHintThreshold && pos.dx.abs() > pos.dy.abs()) {
        hintColor = AppThemes.getArticleColor(widget.appTheme, 'der');
      } else if (pos.dx < -_kHintThreshold && pos.dx.abs() > pos.dy.abs()) {
        hintColor = AppThemes.getArticleColor(widget.appTheme, 'die');
      } else if (pos.dy < -_kHintThreshold && pos.dy.abs() > pos.dx.abs()) {
        hintColor = AppThemes.getArticleColor(widget.appTheme, 'das');
      }
    }
    // REMOVED: else if (showAnswer || _showHint) -> handled by WordCard now to avoid double blending

    if (hintColor != null) {
      return Color.alphaBlend(hintColor.withAlpha(26), cardColor);
    }
    return cardColor;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    final cardsToShow = min(4, widget.words.length - widget.currentIndex);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(cardsToShow, (i) {
          final wordIndex = widget.currentIndex + i;
          if (wordIndex >= widget.words.length) return const SizedBox.shrink();
          final word = widget.words[wordIndex];

          // --- Top Card ---
          if (i == 0) {
            return AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final double sineValue =
                    sin(_shakeController.value * pi * 3); // 3 cycles
                final double offset =
                    sineValue * 10 * (1 - _shakeController.value); // Decay
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: GestureDetector(
                onLongPressStart: (_) {
                  if (widget.showAnswer) {
                    return;
                  }
                  if (widget.isTrainingMode ||
                      widget.gameMode == GameMode.weakPoints) {
                    return; // No hints in training/survival/weakpoints
                  }
                  setState(() => _showHint = true);
                },
                onLongPressEnd: (_) => setState(() => _showHint = false),
                onPanStart: (details) {
                  if (widget.showAnswer ||
                      widget.gameMode == GameMode.autoplay) {
                    return;
                  }
                  _isDragging = true;
                },
                onPanUpdate: (details) {
                  if (widget.showAnswer ||
                      widget.gameMode == GameMode.autoplay) {
                    return;
                  }
                  _positionNotifier.value += details.delta;
                },
                onPanEnd: (details) {
                  if (widget.showAnswer ||
                      widget.gameMode == GameMode.autoplay) {
                    return;
                  }
                  _processSwipeEnd(details);
                },
                child: ValueListenableBuilder<Offset>(
                  valueListenable: _positionNotifier,
                  builder: (context, pos, child) {
                    return Transform.translate(
                      offset: pos,
                      child: WordCard(
                        key: ValueKey(word.id),
                        word: word,
                        showCardAnswer: widget.showAnswer || _showHint,
                        isTrainingMode: widget.isTrainingMode,
                        gameMode: widget.gameMode,
                        backgroundColor:
                            _getCardBackgroundColor(word.article, pos),
                        width: widget.width,
                        height: widget.height,
                        isListening: widget.isListening,
                        onMicTap: widget.onMicTap,
                        muteSpeech: widget.answeredViaVoice,
                      ),
                    );
                  },
                ),
              ),
            );
          }
          // --- Background Cards ---
          else {
            return AnimatedBuilder(
              animation: _deckAnimationController,
              builder: (context, child) {
                final double beginOffsetY = -(i + 1) * 12.0;
                final double endOffsetY = -i * 12.0;
                final offsetY =
                    Tween<double>(begin: beginOffsetY, end: endOffsetY)
                        .evaluate(_deckAnimationController);

                final double beginScale = 1.0 - ((i + 1) * 0.02);
                final double endScale = 1.0 - (i * 0.02);
                final scale = Tween<double>(begin: beginScale, end: endScale)
                    .evaluate(_deckAnimationController);

                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.bottomCenter,
                    child: child,
                  ),
                );
              },
              child: WordCard(
                key: ValueKey(word.id),
                word: word,
                showCardAnswer: false,
                isTrainingMode: widget.isTrainingMode,
                gameMode: widget.gameMode,
                backgroundColor: _getCardBackgroundColor(null, Offset.zero,
                    isInteractive: false),
                width: widget.width,
                height: widget.height,
                isBackgroundCard: true,
              ),
            );
          }
        }).reversed.cast<Widget>().toList(),
      ),
    );
  }
}
