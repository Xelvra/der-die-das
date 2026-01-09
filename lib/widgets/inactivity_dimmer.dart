import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// A widget that dims the screen after a period of inactivity.
class InactivityDimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration timeout;

  const InactivityDimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.timeout = const Duration(seconds: 45),
  });

  @override
  State<InactivityDimmer> createState() => _InactivityDimmerState();
}

class _InactivityDimmerState extends State<InactivityDimmer>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _isDimmed = false;

  bool get _shouldBeActive =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS) && widget.enabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_shouldBeActive) {
      _startTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onInteraction();
    }
  }

  @override
  void didUpdateWidget(InactivityDimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldBeActive &&
        (!oldWidget.enabled ||
            (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)))) {
      // This case is unlikely given the logic but let's be safe
      _startTimer();
    } else if (!_shouldBeActive) {
      _timer?.cancel();
      if (_isDimmed) setState(() => _isDimmed = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, () {
      if (mounted && _shouldBeActive) setState(() => _isDimmed = true);
    });
  }

  void _onInteraction([dynamic _]) {
    if (!_shouldBeActive) return;

    if (_isDimmed) {
      setState(() => _isDimmed = false);
    }
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldBeActive && !_isDimmed) return widget.child;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onInteraction,
      onPointerMove: _onInteraction,
      child: Stack(
        children: [
          widget.child,
          if (_isDimmed)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _isDimmed ? 0.6 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(color: Colors.black),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
