import 'package:der_die_das/app_theme.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final AppTheme currentTheme;

  const LoadingScreen({super.key, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: AppThemes.getBackgroundDecoration(currentTheme),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Der',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppThemes.getArticleColor(currentTheme, 'der'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Die',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppThemes.getArticleColor(currentTheme, 'die'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Das',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppThemes.getArticleColor(currentTheme, 'das'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
