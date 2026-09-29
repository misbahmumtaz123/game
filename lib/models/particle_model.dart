/// Represents a visual pop effect when a bubble is tapped.
class ParticleModel {
  final double x;
  final double y;
  final double size;
  final bool isSuccess;
  double age; // 0.0 (fresh) to 1.0 (vanished)

  ParticleModel({
    required this.x,
    required this.y,
    required this.size,
    required this.isSuccess,
    this.age = 0.0,
  });

  /// Advance age by delta. Returns true if particle is still active.
  bool advanceAge(double delta) {
    age += delta;
    return age <= 1.0;
  }
}
