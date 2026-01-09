import 'package:der_die_das/app_theme.dart';
import 'package:der_die_das/help_screen.dart';
import 'package:der_die_das/models/card_style.dart';
import 'package:der_die_das/models/game_mode.dart';
import 'package:der_die_das/providers/locale_provider.dart';
import 'package:der_die_das/providers/theme_provider.dart';
import 'package:der_die_das/providers/settings_provider.dart';
import 'package:der_die_das/screens/stats_screen.dart';
import 'package:der_die_das/widgets/about_dialog.dart';
import 'package:der_die_das/widgets/coffee_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:der_die_das/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:async';

class AppDrawer extends ConsumerStatefulWidget {
  final GameMode currentMode;
  final GameMode selectedLevel;
  final ValueChanged<GameMode> onModeChanged;

  const AppDrawer({
    super.key,
    required this.currentMode,
    required this.selectedLevel,
    required this.onModeChanged,
  });

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusScopeNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeProvider);

    String getLanguageName(String code) {
      switch (code) {
        case 'cs':
          return 'Čeština';
        case 'de':
          return 'Deutsch';
        case 'en':
          return 'English';
        case 'sk':
          return 'Slovenčina';
        case 'ru':
          return 'Русский';
        case 'ja':
          return '日本語';
        default:
          return code.toUpperCase();
      }
    }

    final languageName = getLanguageName(currentLocale.languageCode);
    final bool isLearningActive = widget.currentMode.index <= GameMode.c2.index;
    final bool isPracticeActive =
        widget.currentMode == GameMode.reviewLearned ||
            widget.currentMode == GameMode.survival ||
            widget.currentMode == GameMode.challenge ||
            widget.currentMode == GameMode.weakPoints;

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final settings = ref.watch(settingsProvider);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowDown):
              DirectionalFocusIntent(TraversalDirection.down),
          SingleActivator(LogicalKeyboardKey.arrowUp):
              DirectionalFocusIntent(TraversalDirection.up),
          SingleActivator(LogicalKeyboardKey.arrowLeft):
              DirectionalFocusIntent(TraversalDirection.left),
          SingleActivator(LogicalKeyboardKey.arrowRight):
              DirectionalFocusIntent(TraversalDirection.right),
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
            node: _focusScopeNode,
            child: FocusTraversalGroup(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 24,
                            bottom: 24,
                            left: 20,
                            right: 20,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text('Der',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppThemes.getArticleColor(
                                                currentTheme, 'der'))),
                                const SizedBox(width: 8),
                                Text('Die',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppThemes.getArticleColor(
                                                currentTheme, 'die'))),
                                const SizedBox(width: 8),
                                Text('Das',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppThemes.getArticleColor(
                                                currentTheme, 'das'))),
                              ],
                            ),
                          ),
                        ),
                        _buildExpansionSection(
                          context,
                          title: l10n.level,
                          icon: Icons.school_outlined,
                          isActive: isLearningActive,
                          children: [
                            _buildModeTile(context, GameMode.a1, 'A1',
                                isSelected: widget.selectedLevel == GameMode.a1,
                                isActive: widget.currentMode == GameMode.a1),
                            _buildModeTile(context, GameMode.a2, 'A2',
                                isSelected: widget.selectedLevel == GameMode.a2,
                                isActive: widget.currentMode == GameMode.a2),
                            _buildModeTile(context, GameMode.b1, 'B1',
                                isSelected: widget.selectedLevel == GameMode.b1,
                                isActive: widget.currentMode == GameMode.b1),
                            _buildModeTile(context, GameMode.b2, 'B2',
                                isSelected: widget.selectedLevel == GameMode.b2,
                                isActive: widget.currentMode == GameMode.b2),
                            _buildModeTile(context, GameMode.c1, 'C1',
                                isSelected: widget.selectedLevel == GameMode.c1,
                                isActive: widget.currentMode == GameMode.c1),
                            _buildModeTile(context, GameMode.c2, 'C2',
                                isSelected: widget.selectedLevel == GameMode.c2,
                                isActive: widget.currentMode == GameMode.c2),
                          ],
                        ),
                        _buildExpansionSection(
                          context,
                          title: l10n.training,
                          icon: Icons.psychology_outlined,
                          isActive: isPracticeActive,
                          children: [
                            _buildModeTile(context, GameMode.reviewLearned,
                                l10n.reviewLearned,
                                icon: Icons.history,
                                isSelected: widget.currentMode ==
                                    GameMode.reviewLearned,
                                isActive: widget.currentMode ==
                                    GameMode.reviewLearned),
                            _buildModeTile(
                                context, GameMode.survival, l10n.survival,
                                icon: Icons.timer_outlined,
                                isSelected:
                                    widget.currentMode == GameMode.survival,
                                isActive:
                                    widget.currentMode == GameMode.survival),
                            _buildModeTile(
                                context, GameMode.challenge, l10n.challenge,
                                icon: Icons.emoji_events_outlined,
                                isSelected:
                                    widget.currentMode == GameMode.challenge,
                                isActive:
                                    widget.currentMode == GameMode.challenge),
                            _buildModeTile(
                                context, GameMode.weakPoints, l10n.weakPoints,
                                icon: Icons.healing_outlined,
                                isSelected:
                                    widget.currentMode == GameMode.weakPoints,
                                isActive:
                                    widget.currentMode == GameMode.weakPoints),
                            _buildModeTile(
                                context, GameMode.autoplay, l10n.autoplay,
                                icon: Icons.play_circle_outline,
                                isSelected:
                                    widget.currentMode == GameMode.autoplay,
                                isActive:
                                    widget.currentMode == GameMode.autoplay),
                          ],
                        ),
                        _buildSimpleTile(
                            context, l10n.menuStats, Icons.bar_chart, () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (context) => const StatsScreen()));
                        }),
                        const Divider(indent: 16, endIndent: 16),
                        _buildSimpleTile(context, l10n.help, Icons.help_outline,
                            () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (context) => const HelpScreen()));
                        }),
                        _buildSimpleTile(
                            context, l10n.about, Icons.info_outline, () {
                          final navigator = Navigator.of(context);
                          navigator.pop();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (!navigator.mounted) return;
                            showGeneralDialog(
                              context: navigator.context,
                              barrierDismissible: true,
                              barrierLabel: 'Dismiss',
                              barrierColor: Colors.black.withValues(alpha: 0.5),
                              transitionDuration:
                                  const Duration(milliseconds: 200),
                              pageBuilder: (context, anim1, anim2) =>
                                  AboutDialogCard(
                                      gameMode: widget.currentMode,
                                      currentTheme: currentTheme),
                            );
                          });
                        }),
                        const Divider(indent: 16, endIndent: 16),
                        _buildExpansionSection(
                          context,
                          title: l10n.colorTheme,
                          icon: Icons.settings_outlined,
                          isActive: false,
                          children: [
                            _buildSettingTile(
                              context,
                              title: languageName,
                              icon: Icons.translate,
                              isActive: false,
                              onTap: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                      children: AppLocalizations
                                          .supportedLocales
                                          .map((locale) {
                                        final isSelected =
                                            currentLocale.languageCode ==
                                                locale.languageCode;
                                        return SimpleDialogOption(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 24),
                                          onPressed: () {
                                            ref
                                                .read(localeProvider.notifier)
                                                .setLocale(locale);
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                isSelected
                                                    ? Icons.radio_button_checked
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme
                                                        .colorScheme.onSurface
                                                        .withValues(alpha: 0.4),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    getLanguageName(
                                                        locale.languageCode),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? theme.colorScheme
                                                              .primary
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                );
                              },
                            ),
                            _buildSettingTile(
                              context,
                              title: l10n.fontSettingsTitle,
                              icon: Icons.style,
                              isActive: false,
                              onTap: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                      children: CardStyle.values.map((style) {
                                        final isSelected =
                                            settings.cardStyle == style;
                                        String styleName;
                                        switch (style) {
                                          case CardStyle.modern:
                                            styleName = l10n.cardStyleModern;
                                            break;
                                          case CardStyle.classic:
                                            styleName = l10n.cardStyleClassic;
                                            break;
                                          case CardStyle.gothic:
                                            styleName = l10n.cardStyleGothic;
                                            break;
                                        }

                                        return SimpleDialogOption(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 24),
                                          onPressed: () {
                                            ref
                                                .read(settingsProvider.notifier)
                                                .setCardStyle(style);
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                isSelected
                                                    ? Icons.radio_button_checked
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme
                                                        .colorScheme.onSurface
                                                        .withValues(alpha: 0.4),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    styleName,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? theme.colorScheme
                                                              .primary
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                );
                              },
                            ),
                            if (isMobile)
                              _buildSettingTile(
                                context,
                                title: l10n.autoSpeech,
                                icon: settings.isAutoSpeechEnabled
                                    ? Icons.record_voice_over
                                    : Icons.voice_over_off,
                                isActive: settings.isAutoSpeechEnabled,
                                onTap: () => ref
                                    .read(settingsProvider.notifier)
                                    .toggleAutoSpeech(
                                        !settings.isAutoSpeechEnabled),
                              ),
                            if (isMobile)
                              _buildSettingTile(
                                context,
                                title: l10n.handsFree,
                                icon: settings.isSpeechRecognitionEnabled
                                    ? Icons.mic
                                    : Icons.mic_off,
                                isActive: settings.isSpeechRecognitionEnabled,
                                onTap: () async {
                                  final success = await ref
                                      .read(settingsProvider.notifier)
                                      .toggleSpeechRecognition(
                                          !settings.isSpeechRecognitionEnabled);
                                  if (!success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              l10n.microphonePermissionError)),
                                    );
                                  }
                                },
                              ),
                            if (isMobile)
                              _buildSettingTile(
                                context,
                                title: l10n.dailyReminder,
                                icon: settings.isNotificationsEnabled
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_off_outlined,
                                isActive: settings.isNotificationsEnabled,
                                onTap: () => ref
                                    .read(settingsProvider.notifier)
                                    .toggleNotifications(
                                        !settings.isNotificationsEnabled,
                                        title: l10n.dailyReminderTitle,
                                        body: l10n.dailyReminderBody),
                              ),
                            if (isMobile)
                              _buildSettingTile(
                                context,
                                title: l10n.haptics,
                                icon: settings.isHapticsEnabled
                                    ? Icons.vibration
                                    : Icons.smartphone,
                                isActive: settings.isHapticsEnabled,
                                onTap: () => ref
                                    .read(settingsProvider.notifier)
                                    .toggleHaptics(!settings.isHapticsEnabled),
                              ),
                            if (isMobile)
                              _buildSettingTile(
                                context,
                                title: l10n.powerSaving,
                                icon: settings.isPowerSavingEnabled
                                    ? Icons.battery_saver
                                    : Icons.battery_std_outlined,
                                isActive: settings.isPowerSavingEnabled,
                                onTap: () => ref
                                    .read(settingsProvider.notifier)
                                    .togglePowerSaving(
                                        !settings.isPowerSavingEnabled),
                              ),
                            const Padding(
                                padding: EdgeInsets.only(
                                    left: 32, top: 8, bottom: 8),
                                child: Divider(height: 1)),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(32, 8, 32, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      AppThemes.getThemeName(
                                          currentTheme, context),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    children: AppTheme.values.map((themeEnum) {
                                      final isSelected =
                                          currentTheme == themeEnum;
                                      final themeData =
                                          AppThemes.getThemeData(themeEnum);
                                      final bgDecoration =
                                          AppThemes.getBackgroundDecoration(
                                              themeEnum) as BoxDecoration;
                                      return InkWell(
                                        onTap: () => ref
                                            .read(themeProvider.notifier)
                                            .setTheme(themeEnum),
                                        borderRadius: BorderRadius.circular(24),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: bgDecoration.color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.dividerColor
                                                      .withValues(alpha: 0.1),
                                              width: isSelected ? 3 : 1,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                        color: theme
                                                            .colorScheme.primary
                                                            .withValues(
                                                                alpha: 0.3),
                                                        blurRadius: 4)
                                                  ]
                                                : null,
                                          ),
                                          child: isSelected
                                              ? Icon(Icons.check,
                                                  size: 18,
                                                  color: themeData
                                                      .colorScheme.primary)
                                              : null,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Divider(
                              height: 1,
                              color: theme.dividerColor.withValues(alpha: 0.1)),
                          AnimatedCoffeeTile(
                            title: l10n.donateTitle,
                            subtitle: l10n.donateSubtitle,
                            onTap: () async {
                              final Uri url = Uri.parse(
                                  'https://buymeacoffee.com/derdiedas');
                              final bool launched = await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                              if (context.mounted && !launched) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Could not open link')));
                              }
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionSection(BuildContext context,
      {required String title,
      required IconData icon,
      required bool isActive,
      required List<Widget> children}) {
    final theme = Theme.of(context);
    return ExpansionTile(
      leading: Icon(icon, color: isActive ? theme.colorScheme.primary : null),
      title: Text(title,
          style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? theme.colorScheme.primary : null)),
      shape: const Border(),
      collapsedShape: const Border(),
      children: children,
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    IconData? icon,
    Widget? leading,
    required VoidCallback onTap,
    bool isActive = false,
    bool isSelected = false,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = isActive
        ? colorScheme.primary
        : (isSelected ? colorScheme.primary.withAlpha(180) : null);
    final effectiveFontWeight = isActive ? FontWeight.bold : FontWeight.normal;

    return ListTile(
      contentPadding:
          contentPadding ?? const EdgeInsets.symmetric(horizontal: 16),
      leading: leading ??
          (icon != null ? Icon(icon, size: 24, color: effectiveColor) : null),
      title: Text(title,
          style: TextStyle(
              fontWeight: effectiveFontWeight, color: effectiveColor)),
      selected: isActive,
      onTap: onTap,
    );
  }

  Widget _buildSimpleTile(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return _buildTile(context, title: title, icon: icon, onTap: onTap);
  }

  Widget _buildSettingTile(BuildContext context,
      {required String title,
      IconData? icon,
      Widget? leading,
      required bool isActive,
      required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final effectiveLeading = leading ??
        (icon != null
            ? Icon(icon,
                size: 20, color: isActive ? theme.colorScheme.primary : null)
            : null);
    return _buildTile(
      context,
      title: title,
      leading: effectiveLeading,
      isActive: isActive,
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
    );
  }

  Widget _buildModeTile(BuildContext context, GameMode mode, String title,
      {IconData? icon, required bool isSelected, required bool isActive}) {
    final IconData effectiveIcon = icon ??
        (isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked);
    return _buildTile(
      context,
      title: title,
      leading: Icon(effectiveIcon,
          size: 20,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : (isSelected
                  ? Theme.of(context).colorScheme.primary.withAlpha(150)
                  : null)),
      isActive: isActive,
      isSelected: isSelected,
      onTap: () {
        widget.onModeChanged(mode);
        Navigator.pop(context);
      },
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
    );
  }
}
