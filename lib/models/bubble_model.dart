import 'dart:math';

/// Represents an active floating bubble in the game arena.
/// Moves completely freely without edge restrictions or collision borders.
class BubbleModel {
  final int id;
  final String emoji;
  final double baseX;
  double y;
  final double z;
  final double phase;
  final double swayAmplitude;

  BubbleModel({
    required this.id,
    required this.emoji,
    required this.baseX,
    required this.y,
    required this.z,
    required this.phase,
    this.swayAmplitude = 0.055,
  });

  /// Dynamic horizontal position with organic curving/swaying without border restrictions
  double get currentX {
    final double drift = sin(phase + y * 7.0) * swayAmplitude;
    return baseX + drift;
  }

  /// Compatibility getter
  double get x => currentX;

  /// Move bubble upwards based on mood speed and depth
  void updatePosition(double speed) {
    y -= speed * z;
  }
}
