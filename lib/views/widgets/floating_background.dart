import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import 'bubble_orb.dart';

/// Configuration for an organically drifting background bubble.
class _BackgroundBubbleConfig {
  final double baseX;
  final double verticalOffset;
  final double speedFactor;
  final double size;
  final double swayAmplitude;
  final double swaySpeed;
  final double opacity;

  const _BackgroundBubbleConfig({
    required this.baseX,
    required this.verticalOffset,
    required this.speedFactor,
    required this.size,
    required this.swayAmplitude,
    required this.swaySpeed,
    this.opacity = 0.45,
  });
}

/// Ambient animated floating bubbles matching current mood theme.
/// Bubbles drift organically with sinusoidal sways instead of moving in straight lines.
class FloatingBackground extends StatefulWidget {
  const FloatingBackground({super.key});

  @override
  State<FloatingBackground> createState() => _FloatingBackgroundState();
}

class _FloatingBackgroundState extends State<FloatingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  // Organically scattered bubble distribution (no grids, columns, or diagonal lines)
  static const List<_BackgroundBubbleConfig> _bubbles = [
    _BackgroundBubbleConfig(
      baseX: 0.12,
      verticalOffset: 0.15,
      speedFactor: 0.024,
      size: 34.0,
      swayAmplitude: 0.05,
      swaySpeed: 0.7,
      opacity: 0.40,
    ),
    _BackgroundBubbleConfig(
      baseX: 0.78,
      verticalOffset: 0.62,
      speedFactor: 0.019,
      size: 50.0,
      swayAmplitude: 0.04,
      swaySpeed: 0.5,
      opacity: 0.48,
    ),
    _BackgroundBubbleConfig(
      baseX: 0.38,
      verticalOffset: 0.88,
      speedFactor: 0.027,
      size: 28.0,
      swayAmplitude: 0.06,
      swaySpeed: 0.9,
      opacity: 0.38,
    ),
    _BackgroundBubbleConfig(
      baseX: 0.88,
      verticalOffset: 0.33,
      speedFactor: 0.022,
      size: 44.0,
      swayAmplitude: 0.05,
      swaySpeed: 0.6,
      opacity: 0.45,
    ),
    _BackgroundBubbleConfig(
      baseX: 0.22,
      verticalOffset: 0.71,
      speedFactor: 0.025,
      size: 38.0,
      swayAmplitude: 0.07,
      swaySpeed: 0.8,
      opacity: 0.42,
    ),
    _BackgroundBubbleConfig(
      baseX: 0.62,
      verticalOffset: 0.08,
      speedFactor: 0.018,
      size: 56.0,
      swayAmplitude: 0.035,
      swaySpeed: 0.45,
      opacity: 0.50,
    ),
    _BackgroundBubbleConfig(
      baseX: 0.05,
      verticalOffset: 0.49,
      speedFactor: 0.028,
      size: 32.0,
      swayAmplitude: 0.06,
      swaySpeed: 0.85,
      opacity: 0.36,
    ),
    _BackgroundBubbleConfig(
      baseX: 0.82,
      verticalOffset: 0.94,
      speedFactor: 0.021,
      size: 46.0,
      swayAmplitude: 0.055,
      swaySpeed: 0.65,
      opacity: 0.44,
    ),
    _BackgroundBubbleConfig(
      baseX: 0.48,
      verticalOffset: 0.27,
      speedFactor: 0.026,
      size: 30.0,
      swayAmplitude: 0.08,
      swaySpeed: 1.0,
      opacity: 0.40,
    ),
    _BackgroundBubbleConfig(
      baseX: 0.30,
      verticalOffset: 0.53,
      speedFactor: 0.020,
      size: 42.0,
      swayAmplitude: 0.065,
      swaySpeed: 0.75,
      opacity: 0.46,
    ),
    _BackgroundBubbleConfig(
      baseX: 0.70,
      verticalOffset: 0.41,
      speedFactor: 0.029,
      size: 26.0,
      swayAmplitude: 0.05,
      swaySpeed: 0.95,
      opacity: 0.35,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameCtrl = context.watch<GameController>();
    final mood = gameCtrl.currentMood;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              final double t = _animController.value * 40.0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (int i = 0; i < _bubbles.length; i++)
                    _buildBubble(i, _bubbles[i], t, width, height, mood),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBubble(
    int index,
    _BackgroundBubbleConfig config,
    double t,
    double screenWidth,
    double screenHeight,
    dynamic mood,
  ) {
    // Continuous upward progress based on individual speed factor and offset
    final double progress = (t * config.speedFactor + config.verticalOffset) % 1.0;
    final double y = 1.15 - progress * 1.35;

    // Organic horizontal swaying (sine wave drift)
    final double horizontalSway =
        sin(t * config.swaySpeed + index * 1.6) * config.swayAmplitude;
    final double x = (config.baseX + horizontalSway).clamp(0.02, 0.94);

    return Positioned(
      left: x * screenWidth,
      top: y * screenHeight,
      child: Opacity(
        opacity: config.opacity,
        child: BubbleOrb(
          emoji: mood.emoji,
          size: config.size,
          tintColor: mood.tintColor,
          time: t,
          phase: index.toDouble(),
        ),
      ),
    );
  }
}
