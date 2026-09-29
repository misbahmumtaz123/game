import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import 'bubble_orb.dart';
import 'glass_card.dart';

/// 3x3 Whack-a-mole board for quick tap mini-games.
class WhackBoard extends StatelessWidget {
  const WhackBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final gameCtrl = context.watch<GameController>();
    final mood = gameCtrl.currentMood;

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
            ),
            itemBuilder: (context, index) {
              final isActive = index == gameCtrl.activeWhackIndex;

              return GestureDetector(
                onTap: () => gameCtrl.handleWhackTap(index),
                child: GlassCard(
                  borderRadius: 24.0,
                  padding: EdgeInsets.zero,
                  backgroundColor:
                      isActive
                          ? Colors.white.withAlpha(65)
                          : Colors.white.withAlpha(25),
                  borderColor:
                      isActive
                          ? Colors.white.withAlpha(220)
                          : Colors.white.withAlpha(60),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size =
                          min(constraints.maxWidth, constraints.maxHeight) *
                          0.88;

                      return Center(
                        child: AnimatedScale(
                          scale: isActive ? 1.12 : 0.0,
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOutBack,
                          child:
                              isActive
                                  ? BubbleOrb(
                                    emoji: gameCtrl.whackCellEmoji,
                                    size: size,
                                    tintColor: mood.tintColor,
                                    time: gameCtrl.elapsedTime,
                                    phase: index.toDouble(),
                                  )
                                  : const SizedBox.shrink(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
