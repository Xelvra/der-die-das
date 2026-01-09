import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color color;
  final double height;
  final bool showThumb;

  const CustomProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 4.0,
    this.showThumb = true,
  });

  @override
  Widget build(BuildContext context) {
    const double thumbSize = 12.0; // Thumb size (ball)

    return SizedBox(
      height: thumbSize, // Must have enough space for the thumb
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final progressWidth = constraints.maxWidth * value.clamp(0.0, 1.0);

          return Stack(
            clipBehavior: Clip
                .none, // Important: so the thumb can "overflow" the line height
            alignment: Alignment.centerLeft,
            children: [
              // 1. The progress line itself
              Container(
                height: height,
                width: progressWidth,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),

              // 2. Thumb (Ball) at the end of the line
              if (showThumb && progressWidth > 0)
                Positioned(
                  left: progressWidth - (thumbSize / 2),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
