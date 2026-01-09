import 'package:der_die_das/models/card_style.dart';
import 'dart:io';
import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/providers/settings_provider.dart';
import 'package:der_die_das/providers/tts_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../app_theme.dart';

const double _kBorderRadius = 24.0;
const double _kBorderWidth = 4.0;

class WordCard extends ConsumerStatefulWidget {
  final Word word;
  final bool showCardAnswer;
  final bool isTrainingMode;
  final GameMode gameMode;
  final Color? backgroundColor;
  final double width;
  final double height;
  final bool isBackgroundCard;
  final bool isListening;
  final VoidCallback? onMicTap;
  final bool muteSpeech;

  const WordCard({
    super.key,
    required this.word,
    this.showCardAnswer = false,
    this.isTrainingMode = false,
    required this.gameMode,
    this.backgroundColor,
    required this.width,
    required this.height,
    this.isBackgroundCard = false,
    this.isListening = false,
    this.onMicTap,
    this.muteSpeech = false,
  });

  @override
  ConsumerState<WordCard> createState() => _WordCardState();
}

class _WordCardState extends ConsumerState<WordCard> {
  bool get _effectivelyShowAnswer =>
      widget.showCardAnswer ||
      (widget.gameMode == GameMode.autoplay && !widget.isBackgroundCard);

  @override
  void didUpdateWidget(WordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showCardAnswer &&
        !oldWidget.showCardAnswer &&
        !widget.isBackgroundCard) {
      if (!widget.muteSpeech) _handleAutoSpeech();
    }
  }

  void _handleAutoSpeech() {
    final settings = ref.read(settingsProvider);
    if (!kIsWeb &&
        (Platform.isAndroid || Platform.isIOS) &&
        settings.isAutoSpeechEnabled &&
        _isTtsAllowed) {
      _speak();
    }
  }

  bool get _isTtsAllowed =>
      widget.gameMode != GameMode.survival &&
      widget.gameMode != GameMode.challenge &&
      widget.gameMode != GameMode.weakPoints;

  void _speak() {
    final textToSpeak = '${widget.word.article} ${widget.word.word}';
    ref.read(ttsServiceProvider).speak(textToSpeak);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = ref.watch(themeProvider);
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final settings = ref.watch(settingsProvider);
    final translation = widget.isBackgroundCard
        ? ''
        : widget.word.getTranslation(ref.watch(localeProvider).languageCode);

    final articleColor =
        AppThemes.getArticleColor(appTheme, widget.word.article);
    final initialBaseColor = widget.backgroundColor ?? theme.cardColor;
    final baseColor = _effectivelyShowAnswer
        ? Color.alphaBlend(articleColor.withAlpha(26), initialBaseColor)
        : initialBaseColor;

    final hsl = HSLColor.fromColor(baseColor);
    final lighterColor =
        hsl.withLightness((hsl.lightness + 0.05).clamp(0.0, 1.0)).toColor();

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_kBorderRadius),
          boxShadow: AppThemes.getCardShadow(theme)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_kBorderRadius),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [lighterColor, baseColor],
              stops: const [0.0, 0.8]),
          border: Border.all(
            color: _effectivelyShowAnswer
                ? articleColor
                : (theme.brightness == Brightness.dark
                    ? Colors.white.withAlpha(25)
                    : Colors.black.withAlpha(70)),
            width: _kBorderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_kBorderRadius),
          child: widget.isBackgroundCard
              ? _buildCardBack(theme)
              : _buildCardFront(
                  theme, articleColor, translation, isMobile, settings),
        ),
      ),
    );
  }

  Widget _buildCardBack(ThemeData theme) {
    return CustomPaint(
      painter: _DiamondPatternPainter(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    width: 3),
                borderRadius: BorderRadius.circular(_kBorderRadius - 2)),
            margin: const EdgeInsets.all(10.0),
          ),
          Center(
              child: Icon(Icons.security,
                  size: widget.width * 0.4,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
        ],
      ),
    );
  }

  Widget _buildCardFront(ThemeData theme, Color articleColor,
      String translation, bool isMobile, SettingsState settings) {
    final bool isModern = settings.cardStyle == CardStyle.modern;
    final bool hasPlural = widget.word.plural != null &&
        widget.word.plural != '—' &&
        widget.word.plural!.isNotEmpty;

    return Stack(
      children: [
        // Glossy top edge
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
                height: 1,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.white
                      .withAlpha(theme.brightness == Brightness.dark ? 30 : 60),
                  Colors.transparent
                ])))),

        // 1. ARTICLE (Top)
        if (!widget.isTrainingMode)
          _PositionedFaded(
            top: 24.0,
            visible: _effectivelyShowAnswer,
            child: isModern
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                        color: articleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(widget.word.article.toUpperCase(),
                        style: TextStyle(
                            fontSize: widget.height * 0.06,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0,
                            color: articleColor)),
                  )
                : Text(widget.word.article.toUpperCase(),
                    style: TextStyle(
                        fontSize: widget.height * 0.08,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8.0,
                        color: articleColor)),
          ),

        // 2. WORD + PLURAL (Center)
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MAIN WORD - Scales down if too long
                SizedBox(
                  width: widget.width - 32, // Card width minus padding
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.word.word,
                      textAlign: TextAlign.center,
                      style: (theme.textTheme.displaySmall ?? const TextStyle())
                          .copyWith(
                        fontWeight: settings.cardStyle == CardStyle.gothic
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontSize: widget.height *
                            (settings.cardStyle == CardStyle.gothic
                                ? 0.15
                                : 0.12),
                        fontFamily: settings.cardStyle == CardStyle.gothic
                            ? GoogleFonts.unifrakturMaguntia().fontFamily
                            : (settings.cardStyle == CardStyle.classic
                                ? (kIsWeb
                                    ? GoogleFonts.notoSerif().fontFamily
                                    : 'serif')
                                : null),
                      ),
                    ),
                  ),
                ),

                // PLURAL - Does NOT scale with word, stays readable
                Visibility(
                  visible: !widget.isTrainingMode && hasPlural,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: AnimatedOpacity(
                    opacity: _effectivelyShowAnswer ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        hasPlural ? '(e ${widget.word.plural})' : '(-)',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: hasPlural
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6)
                                : Colors.transparent,
                            fontStyle: FontStyle.italic,
                            fontSize: widget.height * 0.05),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. AUDIO CONTROLS (Bottom-ish)
        if (isMobile)
          Positioned(
            bottom: widget.height * 0.22,
            left: 0,
            right: 0,
            child: _CardAudioControls(
              isTtsAllowed: _isTtsAllowed,
              onSpeak: _speak,
              isListening: widget.isListening,
              onMicTap: widget.onMicTap,
              gameMode: widget.gameMode,
            ),
          ),

        // 4. TRANSLATION (Bottom) - Forced to single line, scaled down if long
        if (!widget.isTrainingMode)
          _PositionedFaded(
            bottom: 24.0,
            visible: _effectivelyShowAnswer,
            child: SizedBox(
              width: widget.width - 32, // Card width minus padding
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  translation,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: widget.height * 0.06,
                      fontWeight: FontWeight.w400,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PositionedFaded extends StatelessWidget {
  final double? top;
  final double? bottom;
  final bool visible;
  final Widget child;

  const _PositionedFaded(
      {this.top, this.bottom, required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Center(child: child),
      ),
    );
  }
}

class _CardAudioControls extends ConsumerWidget {
  final bool isTtsAllowed;
  final VoidCallback onSpeak;
  final bool isListening;
  final VoidCallback? onMicTap;
  final GameMode gameMode;

  const _CardAudioControls(
      {required this.isTtsAllowed,
      required this.onSpeak,
      required this.isListening,
      this.onMicTap,
      required this.gameMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isTtsAllowed)
          _AudioButton(
            icon: settings.isAutoSpeechEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            isActive: settings.isAutoSpeechEnabled,
            onTap: onSpeak,
            onLongPress: () => ref
                .read(settingsProvider.notifier)
                .toggleAutoSpeech(!settings.isAutoSpeechEnabled),
          ),
        if (gameMode != GameMode.autoplay) ...[
          if (isTtsAllowed) const SizedBox(width: 24),
          _AudioButton(
            icon:
                settings.isSpeechRecognitionEnabled ? Icons.mic : Icons.mic_off,
            isActive: settings.isSpeechRecognitionEnabled,
            isProcessing: isListening,
            onTap: () {
              if (!settings.isSpeechRecognitionEnabled) {
                ref
                    .read(settingsProvider.notifier)
                    .toggleSpeechRecognition(true);
              } else if (!isListening) {
                onMicTap?.call();
              }
            },
            onLongPress: () => ref
                .read(settingsProvider.notifier)
                .toggleSpeechRecognition(false),
          ),
        ],
      ],
    );
  }
}

class _AudioButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isProcessing;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _AudioButton(
      {required this.icon,
      required this.isActive,
      this.isProcessing = false,
      required this.onTap,
      required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size.height * 0.045;
    return InkResponse(
      onTap: onTap,
      onLongPress: onLongPress,
      radius: size * 1.5,
      child: Icon(icon,
          size: size,
          color: isActive
              ? (isProcessing ? Colors.green : theme.colorScheme.primary)
              : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
    );
  }
}

class _DiamondPatternPainter extends CustomPainter {
  final Color color;
  _DiamondPatternPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const double spacing = 20.0;
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
          Offset(i, size.height), Offset(i + size.height, 0), paint);
      canvas.drawLine(
          Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
