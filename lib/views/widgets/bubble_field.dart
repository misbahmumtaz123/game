import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import 'bubble_orb.dart';

/// Free-floating interactive play field without boundary lines or edge restrictions.
/// Tracks tap shots across the arena to accurately evaluate target hits and missed shots.
class BubbleField extends StatelessWidget {
  const BubbleField({super.key});

  @override
  Widget build(BuildContext context) {
    final gameCtrl = context.watch<GameController>();
    final mood = gameCtrl.currentMood;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        // Sort bubbles by depth z so farther ones render behind closer ones
        final sortedBubbles = [...gameCtrl.bubbles]
          ..sort((a, b) => a.z.compareTo(b.z));

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            gameCtrl.handleShot(
              details.localPosition.dx,
              details.localPosition.dy,
              width,
              height,
            );
          },
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Floating bubbles moving completely freely across the screen
              for (final bubble in sortedBubbles)
                Positioned(
                  left: bubble.currentX * width,
                  top: bubble.y * height,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: (0.6 + 0.4 * (bubble.z - 0.7) / 0.6).clamp(
                        0.5,
                        1.0,
                      ),
                      child: BubbleOrb(
                        emoji: bubble.emoji,
                        size: 64.0 * bubble.z,
                        tintColor: mood.tintColor,
                        time: gameCtrl.elapsedTime,
                        phase: bubble.phase,
                      ),
                    ),
                  ),
                ),

              // Pop burst particles and shot tap sparks
              for (final particle in gameCtrl.particles)
                Positioned(
                  left: particle.x - particle.size * (0.5 + particle.age),
                  top: particle.y - particle.size * (0.5 + particle.age),
                  child: IgnorePointer(
                    child: Container(
                      width: particle.size * (1.0 + 2.0 * particle.age),
                      height: particle.size * (1.0 + 2.0 * particle.age),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (particle.isSuccess
                                  ? Colors.white
                                  : Colors.redAccent)
                              .withAlpha(
                                ((255 * (1.0 - particle.age)).clamp(0, 255))
                                    .toInt(),
                              ),
                          width: 3.5,
                        ),
                      ),
                      child: Opacity(
                        opacity: (1.0 - particle.age).clamp(0.0, 1.0),
                        child: Text(
                          particle.isSuccess ? '✨' : '💥',
                          style: TextStyle(
                            fontSize: particle.size * 0.65,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
