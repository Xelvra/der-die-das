import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SttService {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;
  bool _isInitializing = false;
  ValueChanged<bool>? _onStatusChanged;

  /// Registers a status listener without initializing the STT engine.
  /// This prevents permission dialogs from appearing until necessary.
  void setStatusListener(ValueChanged<bool> onStatusChanged) {
    _onStatusChanged = onStatusChanged;
  }

  Future<bool> init() async {
    if (_isAvailable) return true;
    if (_isInitializing) return false;

    _isInitializing = true;
    try {
      _isAvailable = await _speech.initialize(
        onError: (val) {
          debugPrint('STT Error: $val');
          _isInitializing = false;
          _onStatusChanged?.call(false);
        },
        onStatus: (status) {
          debugPrint('STT Status: $status');
          if (status == 'listening') {
            _onStatusChanged?.call(true);
          } else if (status == 'notListening' || status == 'done') {
            _onStatusChanged?.call(false);
          }
        },
      );
    } catch (e) {
      debugPrint('STT Initialization error: $e');
      _isAvailable = false;
    } finally {
      _isInitializing = false;
    }
    return _isAvailable;
  }

  bool get isAvailable => _isAvailable;
  bool get isListening => _speech.isListening;

  Future<void> listen({
    required ValueChanged<String> onResult,
  }) async {
    if (!_isAvailable) {
      bool ok = await init();
      if (!ok) return;
    }

    if (_speech.isListening) return;

    await _speech.listen(
      onResult: (val) {
        final recognizedText = val.recognizedWords.toLowerCase();
        if (recognizedText.contains('der')) {
          onResult('der');
        } else if (recognizedText.contains('die')) {
          onResult('die');
        } else if (recognizedText.contains('das')) {
          onResult('das');
        }
      },
      localeId: 'de-DE',
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  Future<void> cancel() async {
    await _speech.cancel();
  }
}

final sttServiceProvider = Provider((ref) => SttService());
