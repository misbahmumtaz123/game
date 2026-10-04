import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import 'bubble_orb.dart';
import 'glass_card.dart';

/// Top HUD bar displaying Quit button, 3 glowing radiant hearts,
/// a large prominent target in the top bar ("namaya ho"), score, and timer.
/// Completely overflow-free across all screen dimensions.
class GameHeader extends StatelessWidget {
  final VoidCallback? onQuit;
  final GlobalKey? livesKey;
  final GlobalKey? targetKey;
  final GlobalKey? scoreTimerKey;
  final VoidCallback? onHelpTap;

  const GameHeader({
    super.key,
    this.onQuit,
    this.livesKey,
    this.targetKey,
    this.scoreTimerKey,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    final gameCtrl = context.watch<GameController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: GlassCard(
        borderRadius: 24.0,
        borderWidth: 1.2,
        hasShadow: true,
        borderColor: Colors.white.withAlpha(45),
        backgroundColor: Colors.white.withAlpha(25),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            if (availableWidth >= 420.0) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLeftSection(gameCtrl, onQuit),
                  _buildCenterTargetSection(gameCtrl),
                  _buildRightSection(gameCtrl, onHelpTap),
                ],
              );
            }

            return SizedBox(
              width: availableWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLeftSection(gameCtrl, onQuit),
                    const SizedBox(width: 8.0),
                    _buildCenterTargetSection(gameCtrl),
                    const SizedBox(width: 8.0),
                    _buildRightSection(gameCtrl, onHelpTap),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Left section: Close/quit button + 3 glowing radiant hearts
  Widget _buildLeftSection(GameController gameCtrl, VoidCallback? onQuit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onQuit != null) ...[
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(45),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha(40),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
            onPressed: onQuit,
          ),
          const SizedBox(width: 6.0),
        ],
        Container(
          key: livesKey,
          child: _buildLivesIndicator(gameCtrl),
        ),
      ],
    );
  }

  /// Center section: Large, Prominent, Standout Target in the Top Bar ("namaya ho")
  Widget _buildCenterTargetSection(GameController gameCtrl) {
    return Container(
      key: targetKey,
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(160),
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: const Color(0xFFFFD54F).withAlpha(180),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD54F).withAlpha(130),
            blurRadius: 14.0,
            spreadRadius: 1.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TARGET:',
            style: TextStyle(
              color: Color(0xFFFFD54F),
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 6.0),
          // Large prominent BubbleOrb in the top bar
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: BubbleOrb(
              key: ValueKey(gameCtrl.currentTargetEmoji),
              emoji: gameCtrl.currentTargetEmoji,
              size: 42.0, // Large, bold, standout target size in top bar!
              tintColor: const Color(0xFFFFD54F),
              time: gameCtrl.elapsedTime,
            ),
          ),
        ],
      ),
    );
  }

  /// Right section: Score badge, countdown timer badge, and help button
  Widget _buildRightSection(GameController gameCtrl, VoidCallback? onHelpTap) {
    return Container(
      key: scoreTimerKey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(35),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.white.withAlpha(35), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: Color(0xFFFFD54F),
                  size: 14.0,
                ),
                const SizedBox(width: 3.0),
                Text(
                  '${gameCtrl.score}/${gameCtrl.targetScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5.0),
          // Timer Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
            decoration: BoxDecoration(
              color:
                  gameCtrl.timeRemaining <= 10
                      ? Colors.red.withAlpha(60)
                      : Colors.black.withAlpha(35),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color:
                    gameCtrl.timeRemaining <= 10
                        ? Colors.redAccent.withAlpha(160)
                        : Colors.white.withAlpha(35),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color:
                      gameCtrl.timeRemaining <= 10
                          ? Colors.redAccent
                          : Colors.white70,
                  size: 13.0,
                ),
                const SizedBox(width: 2.0),
                Text(
                  '${gameCtrl.timeRemaining}s',
                  style: TextStyle(
                    color:
                        gameCtrl.timeRemaining <= 10
                            ? Colors.redAccent
                            : Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (onHelpTap != null) ...[
            const SizedBox(width: 5.0),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Container(
                padding: const EdgeInsets.all(4.5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(50),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white70,
                  size: 14.0,
                ),
              ),
              onPressed: onHelpTap,
              tooltip: 'How to Play Tutorial',
            ),
          ],
        ],
      ),
    );
  }

  /// Beautified 3-Lives indicator with glowing radiant hearts without any HP text
  Widget _buildLivesIndicator(GameController gameCtrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(40),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: Colors.white.withAlpha(35), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < GameController.maxLives; i++) ...[
            if (i > 0) const SizedBox(width: 3.5),
            AnimatedScale(
              duration: const Duration(milliseconds: 250),
              scale: i < gameCtrl.lives ? 1.0 : 0.85,
              child: Icon(
                Icons.favorite_rounded,
                color:
                    i < gameCtrl.lives
                        ? const Color(0xFFF43F5E) // Radiant rose red
                        : Colors.white.withAlpha(50), // Dimmed empty life
                size: 16.5,
                shadows:
                    i < gameCtrl.lives
                        ? [
                          Shadow(
                            color: const Color(0xFFF43F5E).withAlpha(160),
                            blurRadius: 8.0,
                          ),
                        ]
                        : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
