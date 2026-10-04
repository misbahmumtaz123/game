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
  late final Animation<double> _detail4Anim;
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

    _cardSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
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
      curve: const Interval(0.54, 0.84, curve: Curves.elasticOut),
    );

    _detail2Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.60, 0.88, curve: Curves.elasticOut),
    );

    _detail3Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.66, 0.92, curve: Curves.elasticOut),
    );

    _detail4Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.72, 0.96, curve: Curves.elasticOut),
    );

    _btnScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.78, 1.0, curve: Curves.elasticOut),
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
      scrollable: false,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final isCompact = h < 720;
          final isVeryCompact = h < 620;

          final orbSize = (h * 0.115).clamp(46.0, 92.0);
          final titleFontSize = (h * 0.038).clamp(20.0, 32.0);
          final bannerFontSize = (h * 0.017).clamp(11.5, 14.5);
          final itemVerticalPadding =
              isVeryCompact ? 3.5 : (isCompact ? 5.0 : 8.0);
          final itemHorizontalPadding = isCompact ? 10.0 : 14.0;
          final iconBoxSize = isVeryCompact ? 26.0 : (isCompact ? 30.0 : 34.0);
          final iconSize = isVeryCompact ? 15.0 : (isCompact ? 17.0 : 19.0);
          final labelFontSize = (h * 0.019).clamp(12.5, 15.0);
          final valueFontSize = (h * 0.017).clamp(11.5, 13.5);
          final buttonPaddingV =
              isVeryCompact ? 9.0 : (isCompact ? 11.0 : 14.0);
          final buttonPaddingH = isCompact ? 32.0 : 44.0;
          final buttonFontSize = (h * 0.026).clamp(16.0, 21.0);

          return SizedBox.expand(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 16.0 : 22.0,
                vertical: isVeryCompact ? 2.0 : 6.0,
              ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Hero Mood Orb
                      Transform.translate(
                        offset: Offset(0, idleBob * 0.5),
                        child: ScaleTransition(
                          scale: _orbAnim,
                          child: BubbleOrb(
                            emoji: mood.emoji,
                            size: orbSize,
                            tintColor: mood.tintColor,
                          ),
                        ),
                      ),

                      // Badge
                      ScaleTransition(
                        scale: _badgeScaleAnim,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 10.0 : 14.0,
                            vertical: isCompact ? 3.0 : 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(210),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            '✨ MISSION: REACH HAPPY MOOD ✨',
                            style: TextStyle(
                              color: const Color(0xFF1E293B),
                              fontSize: isVeryCompact
                                  ? 10.0
                                  : (isCompact ? 11.0 : 12.0),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),

                      // Mode Title with Cartoon Pop
                      Transform.rotate(
                        angle: _titleTiltAnim.value + idleWiggle,
                        child: ScaleTransition(
                          scale: _titleScaleAnim,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              mood.gameTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleFontSize,
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
                      ),

                      // Rules Card
                      SlideTransition(
                        position: _cardSlideAnim,
                        child: ScaleTransition(
                          scale: _cardScaleAnim,
                          child: GlassCard(
                            borderRadius: isCompact ? 18.0 : 24.0,
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 14.0 : 18.0,
                              vertical: isVeryCompact
                                  ? 8.0
                                  : (isCompact ? 10.0 : 14.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Goal banner
                                ScaleTransition(
                                  scale: _ruleScaleAnim,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isCompact ? 10.0 : 14.0,
                                      vertical: isVeryCompact
                                          ? 6.0
                                          : (isCompact ? 7.0 : 9.0),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(35),
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: Colors.white.withAlpha(70),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      'Score ${gameCtrl.targetScore} points in 1 minute to break free from your ${mood.name} mood and unlock the Happy Reward! 😊',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: bannerFontSize,
                                        fontWeight: FontWeight.w700,
                                        height: 1.28,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: isVeryCompact
                                      ? 4.0
                                      : (isCompact ? 6.0 : 10.0),
                                ),

                                // Instruction 1: Hit target +10 points
                                ScaleTransition(
                                  scale: _detail1Anim,
                                  child: _buildAlignedInstructionRow(
                                    icon: Icons.gps_fixed_rounded,
                                    title: 'Hit Target',
                                    value: '+10 points',
                                    color: const Color(0xFF4ADE80),
                                    verticalPadding: itemVerticalPadding,
                                    horizontalPadding: itemHorizontalPadding,
                                    iconBoxSize: iconBoxSize,
                                    iconSize: iconSize,
                                    titleFontSize: labelFontSize,
                                    valueFontSize: valueFontSize,
                                  ),
                                ),

                                // Instruction 2: Missing target -3
                                ScaleTransition(
                                  scale: _detail2Anim,
                                  child: _buildAlignedInstructionRow(
                                    icon: Icons.timer_off_rounded,
                                    title: 'Missing Target',
                                    value: '-3 points',
                                    color: const Color(0xFFFBBF24),
                                    verticalPadding: itemVerticalPadding,
                                    horizontalPadding: itemHorizontalPadding,
                                    iconBoxSize: iconBoxSize,
                                    iconSize: iconSize,
                                    titleFontSize: labelFontSize,
                                    valueFontSize: valueFontSize,
                                  ),
                                ),

                                // Instruction 3: Wrong hit -1 life
                                ScaleTransition(
                                  scale: _detail3Anim,
                                  child: _buildAlignedInstructionRow(
                                    icon: Icons.close_rounded,
                                    title: 'Wrong Hit',
                                    value: '-1 life',
                                    color: const Color(0xFFF87171),
                                    verticalPadding: itemVerticalPadding,
                                    horizontalPadding: itemHorizontalPadding,
                                    iconBoxSize: iconBoxSize,
                                    iconSize: iconSize,
                                    titleFontSize: labelFontSize,
                                    valueFontSize: valueFontSize,
                                  ),
                                ),

                                // Instruction 4: Have 3 lives
                                ScaleTransition(
                                  scale: _detail4Anim,
                                  child: _buildAlignedInstructionRow(
                                    icon: Icons.favorite_rounded,
                                    title: 'Total Lives',
                                    value: '3 lives',
                                    color: const Color(0xFFFB7185),
                                    verticalPadding: itemVerticalPadding,
                                    horizontalPadding: itemHorizontalPadding,
                                    iconBoxSize: iconBoxSize,
                                    iconSize: iconSize,
                                    titleFontSize: labelFontSize,
                                    valueFontSize: valueFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Play Button
                      ScaleTransition(
                        scale: _btnScaleAnim,
                        child: Transform.scale(
                          scale:
                              1.0 +
                              (sin(_idleWiggleController.value * pi) * 0.04),
                          child: CustomButton(
                            label: 'PLAY NOW!',
                            icon: Icons.play_arrow_rounded,
                            textColor: mood.backgroundColors.first,
                            fontSize: buttonFontSize,
                            padding: EdgeInsets.symmetric(
                              horizontal: buttonPaddingH,
                              vertical: buttonPaddingV,
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
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlignedInstructionRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double verticalPadding,
    required double horizontalPadding,
    required double iconBoxSize,
    required double iconSize,
    required double titleFontSize,
    required double valueFontSize,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: Colors.white.withAlpha(35),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Left: Aligned Circular Icon Badge
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withAlpha(45),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(180), width: 1.5),
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          const SizedBox(width: 12.0),
          // Center: Aligned Instruction Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // Right: Aligned Value Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: color.withAlpha(45),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: color.withAlpha(160),
                width: 1.2,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: valueFontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
