import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import 'bubble_orb.dart';
import 'glass_card.dart';

/// Clean, borderless top HUD without boundary lines, borders, or shadows.
class GameHeader extends StatelessWidget {
  final VoidCallback? onQuit;

  const GameHeader({super.key, this.onQuit});

  @override
  Widget build(BuildContext context) {
    final gameCtrl = context.watch<GameController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: GlassCard(
        borderRadius: 24.0,
        borderWidth: 0,
        hasShadow: false,
        borderColor: Colors.transparent,
        backgroundColor: Colors.white.withAlpha(35),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Close button + 3 Lives with HP indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onQuit != null) ...[
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: onQuit,
                  ),
                  const SizedBox(width: 8.0),
                ],
                _buildLivesIndicator(gameCtrl),
              ],
            ),

            // Center Target Goal
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TARGET: ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder:
                      (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                  child: BubbleOrb(
                    key: ValueKey(gameCtrl.currentTargetEmoji),
                    emoji: gameCtrl.currentTargetEmoji,
                    size: 38.0,
                    tintColor: const Color(0xFFFFD54F),
                    time: gameCtrl.elapsedTime,
                  ),
                ),
              ],
            ),

            // Score and Timer status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Score vs Goal
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Color(0xFFFFD54F),
                      size: 16.0,
                    ),
                    const SizedBox(width: 3.0),
                    Text(
                      '${gameCtrl.score}/${gameCtrl.targetScore}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                // Timer countdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color:
                          gameCtrl.timeRemaining <= 10
                              ? Colors.redAccent
                              : Colors.white70,
                      size: 14.0,
                    ),
                    const SizedBox(width: 2.0),
                    Text(
                      '${gameCtrl.timeRemaining}s',
                      style: TextStyle(
                        color:
                            gameCtrl.timeRemaining <= 10
                                ? Colors.redAccent
                                : Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivesIndicator(GameController gameCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < GameController.maxLives; i++)
              Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: Text(
                  i < gameCtrl.lives ? '❤️' : '🖤',
                  style: const TextStyle(fontSize: 15.0),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2.0),
        Text(
          'HP: ${gameCtrl.currentLifeHp}/50',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
