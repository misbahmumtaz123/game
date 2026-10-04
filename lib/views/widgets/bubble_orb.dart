import 'dart:math';
import 'package:flutter/material.dart';

/// "4D" Glossy Bubble Orb with dynamic depth, specular shine, and real-time 3D wobble.
class BubbleOrb extends StatelessWidget {
  final String emoji;
  final String? imageAsset;
  final double size;
  final Color tintColor;
  final double time;
  final double phase;
  final bool enableWobble;

  const BubbleOrb({
    super.key,
    this.emoji = '',
    this.imageAsset,
    required this.size,
    required this.tintColor,
    this.time = 0.0,
    this.phase = 0.0,
    this.enableWobble = true,
  });

  @override
  Widget build(BuildContext context) {
    final double rx = enableWobble ? sin(time * 2.0 + phase) * 0.32 : 0.0;
    final double ry = enableWobble ? cos(time * 1.7 + phase) * 0.32 : 0.0;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateX(rx)
        ..rotateY(ry),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.4),
            radius: 0.95,
            colors: [
              Colors.white.withAlpha(130),
              tintColor.withAlpha(70),
              tintColor.withAlpha(195),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withAlpha(150),
            width: max(1.0, size * 0.02),
          ),
          boxShadow: [
            BoxShadow(
              color: tintColor.withAlpha(140),
              blurRadius: size * 0.3,
              offset: Offset(size * 0.06, size * 0.12),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center content: High Quality Image Asset or Emoji
            if (imageAsset != null && imageAsset!.isNotEmpty)
              ClipOval(
                child: Image.asset(
                  imageAsset!,
                  width: size * 0.82,
                  height: size * 0.82,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              )
            else if (emoji.isNotEmpty)
              Text(
                emoji,
                style: TextStyle(
                  fontSize: size * 0.48,
                  decoration: TextDecoration.none,
                ),
              ),

            // Specular reflection / glossy highlight
            Positioned(
              left: size * 0.17,
              top: size * 0.12,
              child: Transform.rotate(
                angle: -0.6,
                child: Container(
                  width: size * 0.3,
                  height: size * 0.14,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(210),
                    borderRadius: BorderRadius.circular(size),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
