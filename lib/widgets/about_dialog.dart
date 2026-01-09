import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:der_die_das/app_theme.dart';
import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/l10n/app_localizations.dart';
import 'package:der_die_das/widgets/adaptive_card_layout.dart';
import 'package:der_die_das/widgets/custom_progress_bar.dart';

class AboutDialogCard extends StatefulWidget {
  final GameMode gameMode;
  final AppTheme currentTheme;

  const AboutDialogCard({
    super.key,
    required this.gameMode,
    required this.currentTheme,
  });

  @override
  State<AboutDialogCard> createState() => _AboutDialogCardState();
}

class _AboutDialogCardState extends State<AboutDialogCard> {
  bool _startAnimation = false;
  String _version = '';
  final FocusScopeNode _focusNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    _loadVersion();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _startAnimation = true);
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = 'v${info.version}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    final hasProgressBar = widget.gameMode == GameMode.survival ||
        widget.gameMode == GameMode.challenge ||
        widget.gameMode == GameMode.reviewLearned ||
        widget.gameMode == GameMode.weakPoints ||
        widget.gameMode == GameMode.autoplay ||
        widget.gameMode.isLevel;

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent()
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) => Navigator.pop(context))
        },
        child: FocusScope(
          node: _focusNode,
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(' '),
              centerTitle: true,
              actions: [
                if (hasProgressBar &&
                    (widget.gameMode == GameMode.survival ||
                        widget.gameMode == GameMode.challenge))
                  const Opacity(
                      opacity: 0,
                      child: IconButton(
                          icon: Icon(Icons.stop_circle_outlined),
                          onPressed: null)),
              ],
              bottom: screenHeight > 50
                  ? const PreferredSize(
                      preferredSize: Size.fromHeight(12.0),
                      child: CustomProgressBar(
                        value: 0.0,
                        color: Colors.transparent,
                        showThumb: false,
                      ),
                    )
                  : null,
            ),
            body: AdaptiveCardLayout(
              card: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppThemes.getCardShadow(theme),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        HSLColor.fromColor(theme.cardColor)
                            .withLightness(
                                (HSLColor.fromColor(theme.cardColor).lightness +
                                        0.05)
                                    .clamp(0.0, 1.0))
                            .toColor(),
                        theme.cardColor
                      ],
                      stops: const [0.0, 0.8],
                    ),
                    border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withAlpha(25)
                            : Colors.black.withAlpha(70),
                        width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: AboutBackgroundPainter(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.05)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    scale: _startAnimation ? 1.0 : 0.8,
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.elasticOut,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Der',
                                            style: TextStyle(
                                                color:
                                                    AppThemes.getArticleColor(
                                                        widget.currentTheme,
                                                        'der'),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 36)),
                                        const SizedBox(width: 8),
                                        Text('Die',
                                            style: TextStyle(
                                                color:
                                                    AppThemes.getArticleColor(
                                                        widget.currentTheme,
                                                        'die'),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 36)),
                                        const SizedBox(width: 8),
                                        Text('Das',
                                            style: TextStyle(
                                                color:
                                                    AppThemes.getArticleColor(
                                                        widget.currentTheme,
                                                        'das'),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 36)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 36),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(_version,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('© 2026 Xelvra',
                                          style: theme.textTheme.bodySmall),
                                      const SizedBox(height: 4),
                                      InkWell(
                                        onTap: () async {
                                          final Uri url = Uri.parse(
                                              'https://github.com/Xelvra/der-die-das');
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.code, size: 16),
                                              const SizedBox(width: 6),
                                              Text('GitHub',
                                                  style: TextStyle(
                                                      color: theme
                                                          .colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 36),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.coffee,
                                              size: 24,
                                              color: Colors.orange.shade400),
                                          const SizedBox(width: 10),
                                          Text(
                                            l10n.donateTitle,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  theme.colorScheme.onSurface,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(l10n.no.toUpperCase(),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(88, 44),
                                              backgroundColor:
                                                  Colors.orange.shade400,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () async {
                                              final Uri url = Uri.parse(
                                                  'https://buymeacoffee.com/derdiedas');
                                              await launchUrl(url,
                                                  mode: LaunchMode
                                                      .externalApplication);
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Text(l10n.yes.toUpperCase(),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AboutBackgroundPainter extends CustomPainter {
  final Color color;
  AboutBackgroundPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.80,
        size.width * 0.5, size.height * 0.90);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 1.0, size.width, size.height * 0.85);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
