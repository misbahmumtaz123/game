import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import '../widgets/bubble_orb.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_scaffold.dart';
import 'game_screen.dart';

/// Screen displaying rules, scoring, and 3-life mechanics with cartoon entrance animation.
class GameIntroScreen extends StatefulWidget {
  const GameIntroScreen({super.key});

  @override
  State<GameIntroScreen> createState() => _GameIntroScreenState();
}

class _GameIntroScreenState extends State<GameIntroScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _idleWiggleController;

  late final Animation<double> _orbAnim;
  late final Animation<double> _titleScaleAnim;
  late final Animation<double> _titleTiltAnim;
  late final Animation<double> _badgeScaleAnim;
  late final Animation<double> _cardScaleAnim;
  late final Animation<Offset> _cardSlideAnim;
  late final Animation<double> _ruleScaleAnim;
  late final Animation<double> _detail1Anim;
  late final Animation<double> _detail2Anim;
  late final Animation<double> _detail3Anim;
  late final Animation<double> _btnScaleAnim;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _idleWiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _orbAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.42, curve: Curves.elasticOut),
    );

    _badgeScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.52, curve: Curves.elasticOut),
    );

    _titleScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.22, 0.65, curve: Curves.elasticOut),
    );

    _titleTiltAnim = Tween<double>(begin: -0.18, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.22, 0.65, curve: Curves.elasticOut),
      ),
    );

    _cardScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.75, curve: Curves.elasticOut),
    );

    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.72, curve: Curves.easeOutBack),
      ),
    );

    _ruleScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.48, 0.82, curve: Curves.elasticOut),
    );

    _detail1Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.58, 0.88, curve: Curves.elasticOut),
    );

    _detail2Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.66, 0.94, curve: Curves.elasticOut),
    );

    _detail3Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.74, 1.0, curve: Curves.elasticOut),
    );

    _btnScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.80, 1.0, curve: Curves.elasticOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _idleWiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameCtrl = context.watch<GameController>();
    final mood = gameCtrl.currentMood;

    return MoodScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _entranceController,
            _idleWiggleController,
          ]),
          builder: (context, _) {
            final idleWiggle =
                sin(_idleWiggleController.value * 2.0 * pi) * 0.035;
            final idleBob = sin(_idleWiggleController.value * pi) * 4.0;

            return Column(
              children: [
                // Hero Mood Orb
                Transform.translate(
                  offset: Offset(0, idleBob * 0.6),
                  child: ScaleTransition(
                    scale: _orbAnim,
                    child: BubbleOrb(
                      emoji: mood.emoji,
                      size: 110.0,
                      tintColor: mood.tintColor,
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),

                // Badge
                ScaleTransition(
                  scale: _badgeScaleAnim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(210),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Text(
                      '✨ MISSION: REACH HAPPY MOOD ✨',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),

                // Mode Title with Cartoon Pop
                Transform.rotate(
                  angle: _titleTiltAnim.value + idleWiggle,
                  child: ScaleTransition(
                    scale: _titleScaleAnim,
                    child: Text(
                      mood.gameTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withAlpha(150),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                          Shadow(
                            color: mood.tintColor.withAlpha(190),
                            blurRadius: 18,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),

                // Rules Card
                SlideTransition(
                  position: _cardSlideAnim,
                  child: ScaleTransition(
                    scale: _cardScaleAnim,
                    child: GlassCard(
                      borderRadius: 24.0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        children: [
                          // Goal banner
                          ScaleTransition(
                            scale: _ruleScaleAnim,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(35),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: Colors.white.withAlpha(70),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                'Score ${gameCtrl.targetScore} points in 1 minute to break free from your ${mood.name} mood and unlock the Happy Reward! 😊',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Scoring rule 1: Target hit
                          ScaleTransition(
                            scale: _detail1Anim,
                            child: _buildDetailRow(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Hit Shifting Target: +10 Score',
                              badgeColor: const Color(0xFF4ADE80),
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          // Scoring rule 2: Missed shot at target
                          ScaleTransition(
                            scale: _detail2Anim,
                            child: _buildDetailRow(
                              icon: Icons.cancel_outlined,
                              label: 'Miss Shot at Target: -5 (Non-targets safe)',
                              badgeColor: const Color(0xFFF87171),
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          // Speed & free floating
                          ScaleTransition(
                            scale: _detail3Anim,
                            child: _buildDetailRow(
                              icon: Icons.speed_rounded,
                              label: '🎈 Balanced Speed Scaling & Free Floating',
                              badgeColor: const Color(0xFFFFD54F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24.0),

                // Play Button
                ScaleTransition(
                  scale: _btnScaleAnim,
                  child: Transform.scale(
                    scale: 1.0 + (sin(_idleWiggleController.value * pi) * 0.04),
                    child: CustomButton(
                      label: 'PLAY NOW!',
                      icon: Icons.play_arrow_rounded,
                      textColor: mood.backgroundColors.first,
                      fontSize: 22.0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48.0,
                        vertical: 16.0,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required Color badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: badgeColor.withAlpha(50),
            shape: BoxShape.circle,
            border: Border.all(color: badgeColor, width: 1.5),
          ),
          child: Icon(icon, color: badgeColor, size: 16.0),
        ),
        const SizedBox(width: 8.0),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
