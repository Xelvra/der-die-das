import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:der_die_das/l10n/app_localizations.dart';

enum AppTheme {
  light,
  dark,
  sepia,
  midnight,
  nordic,
  forest,
  sakura,
  neon,
}

class AppThemes {
  static String getThemeName(AppTheme theme, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (theme) {
      case AppTheme.light:
        return l10n.themeLight;
      case AppTheme.dark:
        return l10n.themeDark;
      case AppTheme.sepia:
        return l10n.themeSepia;
      case AppTheme.midnight:
        return l10n.themeMidnight;
      case AppTheme.nordic:
        return l10n.themeNordic;
      case AppTheme.forest:
        return l10n.themeForest;
      case AppTheme.sakura:
        return l10n.themeSakura;
      case AppTheme.neon:
        return l10n.themeNeon;
    }
  }

  static Color getArticleColor(AppTheme theme, String article) {
    final art = article.toLowerCase();
    switch (theme) {
      case AppTheme.sakura:
        if (art == 'der') return const Color(0xFF5D9CB3);
        if (art == 'die') return const Color(0xFFF06292);
        if (art == 'das') return const Color(0xFF7CB342);
        return Colors.brown.shade300;
      case AppTheme.nordic:
        if (art == 'der') return const Color(0xFF4682B4);
        if (art == 'die') return const Color(0xFFB27077);
        if (art == 'das') return const Color(0xFF6B8E23);
        return Colors.blueGrey;
      case AppTheme.forest:
        if (art == 'der') return const Color(0xFF3E5F5F);
        if (art == 'die') return const Color(0xFFD35D5D);
        if (art == 'das') return const Color(0xFF6B8E23);
        return Colors.brown;
      case AppTheme.neon:
        if (art == 'der') return const Color(0xFF00FBFF);
        if (art == 'die') return const Color(0xFFFF00A2);
        if (art == 'das') return const Color(0xFF3DFF00);
        return Colors.purpleAccent;
      case AppTheme.midnight:
        if (art == 'der') return const Color(0xFF64B5F6);
        if (art == 'die') return const Color(0xFFF87171); // Soft Coral Red
        if (art == 'das') return const Color(0xFF81C784);
        return Colors.blueGrey;
      case AppTheme.sepia:
        if (art == 'der') return const Color(0xFF1B2631);
        if (art == 'die') return const Color(0xFF7B241C);
        if (art == 'das') return const Color(0xFF1D8348);
        return const Color(0xFF5B4636);
      case AppTheme.dark:
        if (art == 'der') return const Color(0xFF42A5F5);
        if (art == 'die') return const Color(0xFFEF5350);
        if (art == 'das') return const Color(0xFF66BB6A);
        return Colors.grey;
      case AppTheme.light:
        if (art == 'der') return const Color(0xFF007AFF);
        if (art == 'die') return const Color(0xFFFF3B30);
        if (art == 'das') return const Color(0xFF34C759);
        return Colors.grey;
    }
  }

  static Decoration getBackgroundDecoration(AppTheme theme) {
    switch (theme) {
      case AppTheme.sakura:
        return const BoxDecoration(color: Color(0xFFFFF0F3));
      case AppTheme.nordic:
        return const BoxDecoration(color: Color(0xFFEDF2F7));
      case AppTheme.forest:
        return const BoxDecoration(color: Color(0xFF141D1A));
      case AppTheme.neon:
        return const BoxDecoration(color: Color(0xFF090117));
      case AppTheme.midnight:
        return const BoxDecoration(color: Color(0xFF020617));
      case AppTheme.sepia:
        return const BoxDecoration(color: Color(0xFFE6D5B8));
      case AppTheme.dark:
        return const BoxDecoration(color: Color(0xFF0A0A0A));
      case AppTheme.light:
        return const BoxDecoration(color: Color(0xFFF8FAFC));
    }
  }

  static List<BoxShadow> getCardShadow(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
    ];
  }

  static ThemeData getThemeData(AppTheme theme) {
    final baseTheme = _getBaseTheme(theme);
    return baseTheme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData _getBaseTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.sakura:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF85A1),
            surface: const Color(0xFFFFF0F3),
            onSurface: const Color(0xFF4A1A2C),
          ),
          cardColor: Colors.white,
          dividerTheme:
              const DividerThemeData(color: Color(0xFFFFD1DC), thickness: 1),
          textTheme: const TextTheme(
            bodySmall: TextStyle(color: Color(0xFF8E5B6F)),
            labelSmall: TextStyle(color: Color(0xFFA1788A)),
          ),
        );

      case AppTheme.nordic:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4682B4),
            surface: const Color(0xFFEDF2F7),
            onSurface: const Color(0xFF1A365D),
          ),
          cardColor: Colors.white,
          dividerTheme:
              const DividerThemeData(color: Color(0xFFCBD5E0), thickness: 1),
          textTheme: const TextTheme(
            bodySmall: TextStyle(color: Color(0xFF4A5568)),
            labelSmall: TextStyle(color: Color(0xFF718096)),
          ),
        );

      case AppTheme.forest:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF386641),
            brightness: Brightness.dark,
            surface: const Color(0xFF141D1A),
            onSurface: const Color(0xFFF2F4F3),
          ),
          cardColor: const Color(0xFF1D2925),
          dividerTheme:
              const DividerThemeData(color: Color(0xFF2D3B36), thickness: 1),
          textTheme: const TextTheme(
            bodySmall: TextStyle(color: Color(0xFFA3B18A)),
            labelSmall: TextStyle(color: Color(0xFF588157)),
          ),
        );

      case AppTheme.neon:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFBC00FF),
            brightness: Brightness.dark,
            surface: const Color(0xFF090117),
            onSurface: Colors.white,
            primary: const Color(0xFFBC00FF),
          ),
          cardColor: const Color(0xFF15022E),
          dividerTheme:
              const DividerThemeData(color: Color(0xFF310B5E), thickness: 1),
          textTheme: const TextTheme(
            bodySmall: TextStyle(color: Color(0xFFC0A9E0)),
            labelSmall: TextStyle(color: Color(0xFF9172C1)),
          ),
        );

      case AppTheme.midnight:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3D5AFE),
            brightness: Brightness.dark,
            surface: const Color(0xFF020617),
            onSurface: Colors.white,
          ),
          cardColor: const Color(0xFF0F172A),
          dividerTheme:
              const DividerThemeData(color: Color(0xFF1E293B), thickness: 1),
          textTheme: const TextTheme(
            bodySmall: TextStyle(color: Color(0xFF94A3B8)),
            labelSmall: TextStyle(color: Color(0xFF64748B)),
          ),
        );

      case AppTheme.dark:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0A84FF),
            brightness: Brightness.dark,
            surface: const Color(0xFF0A0A0A),
            onSurface: const Color(0xFFF2F2F7),
          ),
          cardColor: const Color(0xFF1C1C1E),
          dividerTheme:
              const DividerThemeData(color: Color(0xFF2C2C2E), thickness: 1),
          textTheme: const TextTheme(
            bodySmall: TextStyle(color: Color(0xFF8E8E93)),
            labelSmall: TextStyle(color: Color(0xFF636366)),
          ),
        );

      case AppTheme.sepia:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B4513),
            surface: const Color(0xFFE6D5B8),
            onSurface: const Color(0xFF3E2723),
          ),
          cardColor: const Color(0xFFF2E6CF),
          dividerTheme:
              const DividerThemeData(color: Color(0xFFD4C2A1), thickness: 1),
          textTheme: const TextTheme(
            bodySmall: TextStyle(color: Color(0xFF5D4037)),
            labelSmall: TextStyle(color: Color(0xFF8D6E63)),
          ),
        );

      case AppTheme.light:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007AFF),
            surface: const Color(0xFFF8FAFC),
            onSurface: const Color(0xFF0F172A),
          ),
          cardColor: Colors.white,
          dividerTheme:
              const DividerThemeData(color: Color(0xFFE2E8F0), thickness: 1),
          textTheme: const TextTheme(
            bodySmall: TextStyle(color: Color(0xFF64748B)),
            labelSmall: TextStyle(color: Color(0xFF94A3B8)),
          ),
        );
    }
  }
}
