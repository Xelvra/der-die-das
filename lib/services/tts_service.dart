import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;

    try {
      // Check for German availability
      final dynamic available = await _flutterTts.isLanguageAvailable('de-DE');
      final bool isGermanAvailable =
          available is bool ? available : available.toString() == 'true';

      if (isGermanAvailable) {
        await _flutterTts.setLanguage('de-DE');
      } else {
        // Fallback to generic German if specific de-DE is not found
        await _flutterTts.setLanguage('de');
      }

      // Try to find a native German voice
      if (!kIsWeb) {
        final List<dynamic>? voices =
            (await _flutterTts.getVoices) as List<dynamic>?;
        if (voices != null) {
          try {
            final germanVoice = voices.firstWhere(
              (v) {
                final map = v as Map;
                return map['locale']
                        .toString()
                        .toLowerCase()
                        .contains('de-de') ||
                    map['name'].toString().toLowerCase().contains('german');
              },
              orElse: () => null,
            );
            if (germanVoice != null) {
              final map = germanVoice as Map;
              await _flutterTts.setVoice({
                'name': map['name'].toString(),
                'locale': map['locale'].toString()
              });
            }
          } catch (_) {
            // Ignore if voice selection fails, stay with default German
          }
        }
      }

      // Configure TTS parameters
      await _flutterTts
          .setSpeechRate(0.5); // Slightly slower for better learning
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // iOS specific configuration
      if (!kIsWeb && Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
        );
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS Initialization warning: $e');
    }
  }

  /// Wake up the TTS engine silently to avoid lag on first spoken word
  Future<void> warmUp() async {
    try {
      await _init();
      if (_isInitialized) {
        await _flutterTts.setVolume(0.0);
        await _flutterTts.setLanguage('de-DE'); // Ensure German
        await _flutterTts.speak(' ');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await _flutterTts.setVolume(1.0);
      }
    } catch (e) {
      debugPrint('TTS Warmup warning: $e');
    }
  }

  Future<void> speak(String text) async {
    // Try to initialize if not already done
    if (!_isInitialized) {
      await _init();
    }

    // If still not initialized (e.g. error occurred), exit safely
    if (!_isInitialized) return;

    try {
      if (text.isNotEmpty) {
        // Re-enforce German language before each speak to be 100% sure
        await _flutterTts.setLanguage('de-DE');
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint('TTS Speak warning: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS Stop warning: $e');
    }
  }
}
