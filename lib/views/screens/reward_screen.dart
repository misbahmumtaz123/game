import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import '../../models/mood_model.dart';
import '../widgets/bubble_orb.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import 'game_screen.dart';
import 'mood_selection_screen.dart';

/// Screen displaying the result.
/// Uplifting Quote and Funny Joke are EXCLUSIVE REWARDS unlocked ONLY when reaching the target score!
class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with SingleTickerProviderStateMixin {
  bool _revealedPunchline = false;
  late final AnimationController _bounceController;

  // Snapshot frozen at game-end. Never re-read from the live provider
  // so that startGame() resets on "Play Again" cannot flip reward state.
  late final bool _isWon;
  late final HappyRewardItem _reward;
  late final int _finalScore;
  late final int _finalTargetScore;
  late final int _finalLives;
  late final List<Color> _backgroundColors;
  late final Color _tintColor;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Snapshot everything right now, before any rebuild can change it
    final gameCtrl = context.read<GameController>();
    _isWon = gameCtrl.isGoalReached || gameCtrl.score >= gameCtrl.targetScore;
    _reward = gameCtrl.currentReward;
    _finalScore = gameCtrl.score;
    _finalTargetScore = gameCtrl.targetScore;
    _finalLives = gameCtrl.lives;
    _tintColor = gameCtrl.currentMood.tintColor;
    _backgroundColors = _isWon
        ? MoodModel.happyBackgroundColors
        : gameCtrl.currentMood.backgroundColors;
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use frozen snapshots — NOT context.watch — so startGame() resets never
    // accidentally flip the reward screen back to "locked" during navigation.
    final bool isWon = _isWon;
    final reward = _reward;

    // Use frozen background — not re-derived from live provider
    final backgroundColors = _backgroundColors;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundColors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 22.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  // Title Header
                  Text(
                    isWon
                        ? '🌟 MOOD TRANSFORMED! 🌟'
                        : (_finalLives <= 0
                            ? '💔 ALL LIVES LOST'
                            : '⏱️ TIME\'S UP'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Hero Orb: Smiling face ONLY when target is achieved
                  AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, _) {
                      return BubbleOrb(
                        emoji:
                            isWon
                                ? '😊'
                                : (_finalLives <= 0 ? '💔' : '⌛'),
                        size: 140.0,
                        tintColor:
                            isWon ? Colors.amber : _tintColor,
                        time: _bounceController.value * 4.0,
                      );
                    },
                  ),

                  const SizedBox(height: 14.0),

                  // Headline
                  Text(
                    isWon
                        ? 'You achieved your target!\nYou are in a Happy Mood now! 😊'
                        : (_finalLives <= 0
                            ? 'You ran out of lives!'
                            : 'Time expired before reaching target!'),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10.0),

                  // Score recap badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.white.withAlpha(120)),
                    ),
                    child: Text(
                      'Score: $_finalScore / Goal: $_finalTargetScore pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // -------------------------------------------------------------
                  // EXCLUSIVE REWARD SECTION: ONLY SHOWN IF TARGET SCORE ACHIEVED
                  // -------------------------------------------------------------
                  if (isWon) ...[
                    // REWARD 1: Uplifting Quote
                    GlassCard(
                      borderRadius: 20.0,
                      padding: const EdgeInsets.all(18.0),
                      backgroundColor: Colors.white.withAlpha(65),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Text('✨ ', style: TextStyle(fontSize: 18.0)),
                              Text(
                                'Your Happy Reward: Uplifting Quote',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '“${reward.quote}”',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontStyle: FontStyle.italic,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '— ${reward.author}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // REWARD 2: Funny Joke
                    GlassCard(
                      borderRadius: 20.0,
                      padding: const EdgeInsets.all(18.0),
                      backgroundColor: Colors.white.withAlpha(65),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            children: [
                              Text('😂 ', style: TextStyle(fontSize: 18.0)),
                              Text(
                                'Your Happy Reward: Funny Joke',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            reward.jokeQuestion,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          if (_revealedPunchline)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD54F).withAlpha(220),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Text(
                                reward.jokePunchline,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            )
                          else
                            Center(
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withAlpha(45),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                ),
                                onPressed:
                                    () => setState(
                                      () => _revealedPunchline = true,
                                    ),
                                label: const Text(
                                  'Tap to reveal punchline 😄',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // -------------------------------------------------------------
                    // DEFEAT / LOSS SECTION: LOCKED REWARD (minimal)
                    // -------------------------------------------------------------
                    GlassCard(
                      borderRadius: 20.0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 18.0,
                      ),
                      backgroundColor: Colors.white.withAlpha(30),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFFFFD54F),
                            size: 24.0,
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Happy Reward Locked',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 26.0),

                  // Action Button
                  CustomButton(
                    label: isWon ? '🎉 Play Again!' : '🔥 Try Again!',
                    icon: Icons.replay_rounded,
                    textColor: backgroundColors.first,
                    fontSize: 20.0,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12.0),

                  // Choose another bad mood
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MoodSelectionScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: Text(
                        'Change Bad Mood',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
