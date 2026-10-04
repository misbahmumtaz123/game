import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import 'bubble_orb.dart';
import 'glass_card.dart';

/// Prominent, large dedicated target banner placed on its own line in the play screen.
/// Displays a large, vibrant, glowing target bubble that stands out ("namaya ho") with +10 points badge.
class TargetBanner extends StatelessWidget {
  final GameController gameCtrl;
  final GlobalKey? targetKey;
  final VoidCallback? onHelpTap;

  const TargetBanner({
    super.key,
    required this.gameCtrl,
    this.targetKey,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: targetKey,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      child: GlassCard(
        borderRadius: 20.0,
        borderWidth: 1.5,
        borderColor: const Color(0xFFFFD54F).withAlpha(120),
        backgroundColor: const Color(0xFF0F172A).withAlpha(160),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        hasShadow: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Large, Prominent, Standout Target Emoji Orb with Radiant Ambient Glow
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD54F).withAlpha(140),
                            blurRadius: 18.0,
                            spreadRadius: 2.5,
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: BubbleOrb(
                          key: ValueKey(gameCtrl.currentTargetEmoji),
                          emoji: gameCtrl.currentTargetEmoji,
                          size: 50.0, // Large, bold, standout size
                          tintColor: const Color(0xFFFFD54F),
                          time: gameCtrl.elapsedTime,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10.0),

                    // 2. Clear instructions & Reward Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'TARGET:',
                              style: TextStyle(
                                color: Color(0xFFFFD54F),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.5,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withAlpha(45),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withAlpha(180),
                                  width: 1.0,
                                ),
                              ),
                              child: const Text(
                                '+10 PTS',
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        const Text(
                          'Pop this emoji to score!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 8.0),

                    // 3. Optional How to Play / Help Button
                    if (onHelpTap != null)
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(5.0),
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
                            color: Colors.white,
                            size: 15.0,
                          ),
                        ),
                        onPressed: onHelpTap,
                        tooltip: 'How to Play Tutorial',
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
