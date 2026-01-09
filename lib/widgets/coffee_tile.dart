import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedCoffeeTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AnimatedCoffeeTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<AnimatedCoffeeTile> createState() => _AnimatedCoffeeTileState();
}

class _AnimatedCoffeeTileState extends State<AnimatedCoffeeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0.2), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: -0.2), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) =>
            Transform.rotate(angle: _animation.value, child: child),
        child: Icon(Icons.coffee, color: Colors.orange.shade400),
      ),
      title: Text(widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle:
          Text(widget.subtitle, style: Theme.of(context).textTheme.bodySmall),
      onTap: widget.onTap,
    );
  }
}
