import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:der_die_das/l10n/app_localizations.dart';
import 'package:der_die_das/providers/settings_provider.dart';
import 'package:der_die_das/providers/theme_provider.dart';
import 'package:der_die_das/app_theme.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpItem {
  final String id;
  final IconData icon;
  final String Function(AppLocalizations) titleBuilder;
  final Widget Function(BuildContext, AppLocalizations) contentBuilder;

  _HelpItem({
    required this.id,
    required this.icon,
    required this.titleBuilder,
    required this.contentBuilder,
  });
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String? _activeTabId;
  late Map<String, _HelpItem> _itemsMap;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _itemsMap = {
      'swiping': _HelpItem(
        id: 'swiping',
        icon: Icons.touch_app,
        titleBuilder: (l10n) => l10n.helpSwiping,
        contentBuilder: _buildSwipingContent,
      ),
      'tips': _HelpItem(
        id: 'tips',
        icon: Icons.lightbulb_outline,
        titleBuilder: (l10n) => l10n.helpTips,
        contentBuilder: _buildTipsContent,
      ),
      'keyboard': _HelpItem(
        id: 'keyboard',
        icon: Icons.keyboard,
        titleBuilder: (l10n) => l10n.helpKeyboard,
        contentBuilder: _buildKeyboardContent,
      ),
    };
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onReorder(int oldIndex, int newIndex) {
    final settings = ref.read(settingsProvider);
    final List<String> newOrder = List.from(settings.helpTabOrder);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);

    ref.read(settingsProvider.notifier).updateHelpTabOrder(newOrder);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final tabOrder = settings.helpTabOrder;

    _activeTabId ??= tabOrder.first;

    final activeItem = _itemsMap[_activeTabId] ?? _itemsMap[tabOrder.first]!;
    final borderColor = theme.dividerColor.withValues(alpha: 0.2);

    return Shortcuts(
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
          node: _focusNode,
          autofocus: true,
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: MediaQuery.of(context).size.height > 250
                ? AppBar(
                    title: Text(activeItem.titleBuilder(l10n)),
                    backgroundColor: theme.colorScheme.surface,
                    scrolledUnderElevation: 0,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    bottom: const PreferredSize(
                      preferredSize: Size.fromHeight(12.0),
                      child: SizedBox(height: 12.0),
                    ),
                  )
                : null,
            body: MediaQuery.of(context).size.height < 150
                ? const SizedBox.shrink()
                : Stack(
                    children: [
                      // --- Binder Sheet ---
                      Positioned.fill(
                        child: Column(
                          children: [
                            const SizedBox(height: 49),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(16, 0, 16,
                                    24 + MediaQuery.of(context).padding.bottom),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 24),
                                    child: activeItem.contentBuilder(
                                        context, l10n),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- Tab Bar ---
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 51,
                        child: Container(
                          padding: const EdgeInsets.only(left: 16),
                          child: Theme(
                            data: theme.copyWith(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                            ),
                            child: FocusTraversalGroup(
                              child: ReorderableListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: tabOrder.length,
                                onReorder: _onReorder,
                                buildDefaultDragHandles: false,
                                proxyDecorator: (child, index, animation) =>
                                    Material(
                                        color: Colors.transparent,
                                        child: child),
                                itemBuilder: (context, index) {
                                  final id = tabOrder[index];
                                  final item = _itemsMap[id]!;
                                  final isActive = id == _activeTabId;

                                  return ReorderableDelayedDragStartListener(
                                    key: ValueKey(id),
                                    index: index,
                                    child: _buildTab(
                                        context, item, isActive, borderColor),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
      BuildContext context, _HelpItem item, bool isActive, Color borderColor) {
    final theme = Theme.of(context);

    return InkWell(
      // Changed GestureDetector to InkWell for focus
      onTap: () => setState(() => _activeTabId = item.id),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        width: 60,
        height: 50,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: isActive
              ? theme.cardColor
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          border: Border(
            top: BorderSide(color: borderColor),
            left: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
            bottom: isActive ? BorderSide.none : BorderSide(color: borderColor),
          ),
        ),
        child: Icon(
          item.icon,
          color: isActive ? theme.colorScheme.primary : theme.disabledColor,
          size: 26,
        ),
      ),
    );
  }

  // --- Swiping Content ---
  Widget _buildSwipingContent(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.helpSwipingContent,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        const SizedBox(height: 32),
        _buildActionCard(
          context,
          icon: Icons.swipe_left_outlined,
          label: 'Die',
          desc: l10n.swipeLeft,
          color: AppThemes.getArticleColor(currentTheme, 'die'),
        ),
        _buildActionCard(
          context,
          icon: Icons.swipe_up_outlined,
          label: 'Das',
          desc: l10n.swipeUp,
          color: AppThemes.getArticleColor(currentTheme, 'das'),
        ),
        _buildActionCard(
          context,
          icon: Icons.swipe_right_outlined,
          label: 'Der',
          desc: l10n.swipeRight,
          color: AppThemes.getArticleColor(currentTheme, 'der'),
        ),
        _buildActionCard(
          context,
          icon: Icons.touch_app_outlined,
          label: l10n.helpReveal,
          desc: l10n.longPressHint,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String desc,
      required Color color}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 18)),
                Text(desc, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Tips Content ---
  Widget _buildTipsContent(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.helpTipsContent,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        const SizedBox(height: 32),
        _buildTipSection(context, 'Grammatische Endungen', [
          _TipData(l10n.tipIg, 'Der',
              AppThemes.getArticleColor(currentTheme, 'der')),
          _TipData(l10n.tipUng, 'Die',
              AppThemes.getArticleColor(currentTheme, 'die')),
          _TipData(l10n.tipChen, 'Das',
              AppThemes.getArticleColor(currentTheme, 'das')),
        ]),
        const SizedBox(height: 24),
        _buildTipSection(context, 'Bedeutungsgruppen', [
          _TipData(l10n.tipTime, 'Der',
              AppThemes.getArticleColor(currentTheme, 'der')),
          _TipData(l10n.tipAuto, 'Der',
              AppThemes.getArticleColor(currentTheme, 'der')),
          _TipData(l10n.tipForeign, 'Das',
              AppThemes.getArticleColor(currentTheme, 'das')),
        ]),
      ],
    );
  }

  Widget _buildTipSection(
      BuildContext context, String title, List<_TipData> tips) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.disabledColor)),
        ),
        ...tips.map((tip) =>
            _buildTipCard(context, tip.endings, tip.article, tip.color)),
      ],
    );
  }

  Widget _buildTipCard(
      BuildContext context, String endings, String article, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(6)),
            child: Text(article,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(endings,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }

  // --- Keyboard Content ---
  Widget _buildKeyboardContent(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.helpKeyboardContent,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        const SizedBox(height: 32),
        _buildKbdSection(context, l10n.helpArrows, [
          Center(
            child: Column(
              children: [
                _buildKeyVisual(context, '↑', 'Das',
                    AppThemes.getArticleColor(currentTheme, 'das')),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildKeyVisual(context, '←', 'Die',
                          AppThemes.getArticleColor(currentTheme, 'die')),
                      const SizedBox(width: 8),
                      _buildKeyVisual(context, '↓', l10n.helpReveal,
                          theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      _buildKeyVisual(context, '→', 'Der',
                          AppThemes.getArticleColor(currentTheme, 'der')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 32),
        _buildKbdSection(context, 'WASD', [
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      right: 12), // Shift W slightly to the left
                  child: _buildKeyVisual(context, 'W', 'Das',
                      AppThemes.getArticleColor(currentTheme, 'das')),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildKeyVisual(context, 'A', 'Die',
                          AppThemes.getArticleColor(currentTheme, 'die')),
                      const SizedBox(width: 8),
                      _buildKeyVisual(context, 'S', l10n.helpReveal,
                          theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      _buildKeyVisual(context, 'D', 'Der',
                          AppThemes.getArticleColor(currentTheme, 'der')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 32),
        _buildKbdSection(context, l10n.helpSystem, [
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildKeyVisual(
                      context, 'M', l10n.keyMenu, theme.colorScheme.onSurface),
                  const SizedBox(width: 8),
                  // Invisible spacer to match the middle key width (like 'S' in WASD)
                  const SizedBox(width: 52),
                  const SizedBox(width: 8),
                  _buildKeyVisual(
                      context, 'Esc', l10n.back, theme.colorScheme.onSurface),
                ],
              ),
            ),
          ),
        ]),
        const SizedBox(height: 32),
        _buildKbdSection(context, l10n.help, [
          Center(
            child: _buildKeyVisual(
              context,
              'Space',
              l10n.helpReveal,
              theme.colorScheme.primary,
              width: 172,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildKbdSection(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(title.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.disabledColor)),
        ),
        ...children,
      ],
    );
  }

  Widget _buildKeyVisual(
      BuildContext context, String label, String desc, Color color,
      {double width = 52}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: width,
          height: 52,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.15), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: const Offset(0, 3),
                  blurRadius: 4)
            ],
          ),
          child: Center(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20))),
        ),
        const SizedBox(height: 8),
        Text(desc,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 10)),
      ],
    );
  }
}

class _TipData {
  final String endings;
  final String article;
  final Color color;
  _TipData(this.endings, this.article, this.color);
}
