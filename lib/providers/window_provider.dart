import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'shared_prefs_provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final bool isDesktop =
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

class WindowState {
  final double? width;
  final double? height;
  final double? x;
  final double? y;

  const WindowState({this.width, this.height, this.x, this.y});
}

class WindowNotifier extends Notifier<WindowState> with WindowListener {
  static const _kWidth = 'window_width';
  static const _kHeight = 'window_height';
  static const _kX = 'window_x';
  static const _kY = 'window_y';

  Timer? _debounceTimer;

  @override
  WindowState build() {
    if (isDesktop) {
      windowManager.addListener(this);
    }

    final prefs = ref.watch(sharedPreferencesProvider);
    return WindowState(
      width: prefs.getDouble(_kWidth),
      height: prefs.getDouble(_kHeight),
      x: prefs.getDouble(_kX),
      y: prefs.getDouble(_kY),
    );
  }

  @override
  void onWindowResized() {
    _saveDebounced();
  }

  @override
  void onWindowMoved() {
    _saveDebounced();
  }

  void _saveDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      saveWindowProperties();
    });
  }

  Future<void> saveWindowProperties() async {
    if (!isDesktop) return;

    try {
      final Rect bounds = await windowManager.getBounds();

      // Safety check: Don't save invalid dimensions
      if (bounds.width < 100 || bounds.height < 100) return;

      final prefs = ref.read(sharedPreferencesProvider);

      await prefs.setDouble(_kWidth, bounds.width);
      await prefs.setDouble(_kHeight, bounds.height);
      await prefs.setDouble(_kX, bounds.left);
      await prefs.setDouble(_kY, bounds.top);
    } catch (e) {
      // Ignore window manager errors
    }
  }
}

final windowProvider =
    NotifierProvider<WindowNotifier, WindowState>(WindowNotifier.new);
