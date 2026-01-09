import 'package:flutter/material.dart';
import 'package:der_die_das/l10n/app_localizations.dart';

class LevelCompleteDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const LevelCompleteDialog({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        children: [
          const Icon(Icons.celebration_rounded, size: 72, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            l10n.levelComplete,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        l10n.keepItUp,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onContinue();
          },
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(l10n.continues),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }
}
