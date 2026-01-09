import 'dart:math';
import 'package:flutter/material.dart';

/// Common layout ensuring the card always has the same size
/// and is at the same position (pixel-perfect) throughout the application.
class AdaptiveCardLayout extends StatelessWidget {
  final Widget card;
  final Widget? bottomContent;

  const AdaptiveCardLayout({
    super.key,
    required this.card,
    this.bottomContent,
  });

  static const double aspectRatio = 1.55;
  static const double bottomSpaceHeight = 92.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 50 || constraints.maxHeight < 50) {
        return const SizedBox.shrink();
      }

      double cardWidth = min(constraints.maxWidth * 0.82, 400.0);
      double cardHeight = cardWidth * aspectRatio;

      final double maxHeightAllowed = constraints.maxHeight * 0.90;
      if (cardHeight > maxHeightAllowed) {
        cardHeight = maxHeightAllowed;
        cardWidth = cardHeight / aspectRatio;
      }

      if (cardHeight < 280) {
        cardHeight = 280;
        cardWidth = cardHeight / aspectRatio;
      }

      return Column(
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: card,
              ),
            ),
          ),
          if (constraints.maxHeight > 140)
            SafeArea(
              top: false,
              bottom: true,
              child: SizedBox(
                height: bottomSpaceHeight,
                width: cardWidth, // Match card width exactly
                child: bottomContent ?? const SizedBox.shrink(),
              ),
            ),
        ],
      );
    });
  }
}
