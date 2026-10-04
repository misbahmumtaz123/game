import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import '../widgets/bubble_orb.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_scaffold.dart';
import 'mood_selection_screen.dart';

/// Welcome / Splash Screen introducing Mood Switcher.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wobbleController;

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameCtrl = context.watch<GameController>();

    return MoodScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero 4D Bubble Orb with App Logo
            AnimatedBuilder(
              animation: _wobbleController,
              builder: (context, _) {
                return BubbleOrb(
                  imageAsset: 'assets/icon/app_icon_1024.png',
                  size: 165.0,
                  tintColor: const Color(0xFFFFD54F),
                  time: _wobbleController.value * 10.0,
                );
              },
            ),

            const SizedBox(height: 28.0),

            // Game Title
            const Text(
              'Mood Switcher',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 42.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10.0),

            // Subtitle / Description
            const Text(
              'Switch your mood from gloom to joy by popping emoji bubbles!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32.0),

            // High Score pill if present
            if (gameCtrl.bestScore > 0) ...[
              GlassCard(
                borderRadius: 20.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFFFD54F),
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Best Score: ${gameCtrl.bestScore}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
            ],

            // Action Button
            CustomButton(
              label: 'Start Game',
              icon: Icons.play_arrow_rounded,
              textColor: gameCtrl.currentMood.backgroundColors.first,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoodSelectionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
