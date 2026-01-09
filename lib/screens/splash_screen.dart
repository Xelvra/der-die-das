import 'package:der_die_das/providers/database_providers.dart';
import 'package:der_die_das/providers/game_session_provider.dart';
import 'package:der_die_das/providers/tts_provider.dart';
import 'package:der_die_das/widgets/loading_screen.dart';
import 'package:der_die_das/screens/home_screen.dart';
import 'package:der_die_das/providers/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late Future<void> _splashFuture;

  @override
  void initState() {
    super.initState();
    _splashFuture = _initializeSplash();
  }

  Future<void> _initializeSplash() async {
    // Run initialization tasks in parallel
    final vocabRepo = ref.read(vocabularyRepositoryProvider);
    final ttsService = ref.read(ttsServiceProvider);

    // Warm up TTS (to prevent delay on first word)
    final ttsWarmup = ttsService.warmUp();

    // Get stats for debug purposes (also initializes the Vocabulary DB)
    try {
      final totalCount = await vocabRepo.getTotalWordCount();
      if (kDebugMode) {
        print('Total vocabulary words in database: $totalCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing statistics: $e');
      }
    }

    // Initialize Game Session (load preferences, words etc.)
    final gameInit = ref.read(gameSessionProvider.notifier).initSession();

    // Wait for everything to warm up
    try {
      await Future.wait([
        ttsWarmup,
        gameInit,
      ]);
    } catch (e) {
      // Ignore TTS errors on startup, app must continue
      if (kDebugMode) print('TTS Warmup warning: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _splashFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error initializing database: ${snapshot.error}'),
              ),
            );
          }
          // Navigate to home screen after completion
          return const HomeScreen();
        } else {
          final currentTheme = ref.watch(themeProvider);
          return LoadingScreen(currentTheme: currentTheme);
        }
      },
    );
  }
}
