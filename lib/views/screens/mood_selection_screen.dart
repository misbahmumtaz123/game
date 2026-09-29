import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import '../widgets/bubble_orb.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_scaffold.dart';
import 'game_intro_screen.dart';

/// Screen allowing players to select their starting bad mood and set their target goal score.
class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wobbleController;

  static const List<int> _scorePresets = [100, 250, 500, 750];

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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
    final moods = gameCtrl.moods;
    final selectedMoodIndex = gameCtrl.currentMoodIndex;
    final currentTargetScore = gameCtrl.targetScore;

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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          children: [
            // Header
            const Text(
              'Select Your Starting Mood',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6.0),
            const Text(
              'Pop away the negativity to reach the Happy Mood!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20.0),

            // Bad Mood Selection Cards
            AnimatedBuilder(
              animation: _wobbleController,
              builder: (context, _) {
                final time = _wobbleController.value * 12.0;

                return Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  alignment: WrapAlignment.center,
                  children: [
                    for (int i = 0; i < moods.length; i++)
                      _buildMoodCard(
                        context,
                        moodIndex: i,
                        isSelected: selectedMoodIndex == i,
                        time: time,
                        gameCtrl: gameCtrl,
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24.0),

            // Target Score Goal Selector Card
            GlassCard(
              borderRadius: 22.0,
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🎯 Goal for Happy Mood: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54F),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Text(
                          '$currentTargetScore pts',
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 17.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'What score will transform your mood to Happy? 😊',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13.0),
                  ),
                  const SizedBox(height: 14.0),

                  // Quick Preset Chips
                  Wrap(
                    spacing: 10.0,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final preset in _scorePresets)
                        ChoiceChip(
                          label: Text(
                            '$preset',
                            style: TextStyle(
                              color:
                                  currentTargetScore == preset
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: currentTargetScore == preset,
                          selectedColor: const Color(0xFFFFD54F),
                          backgroundColor: Colors.white.withAlpha(30),
                          onSelected: (_) => gameCtrl.setTargetScore(preset),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // Stepper row for fine adjustment
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline_rounded,
                          color: Colors.white,
                        ),
                        onPressed:
                            currentTargetScore > 50
                                ? () => gameCtrl.setTargetScore(
                                  currentTargetScore - 50,
                                )
                                : null,
                      ),
                      Slider(
                        value: currentTargetScore.toDouble().clamp(50.0, 1000.0),
                        min: 50.0,
                        max: 1000.0,
                        divisions: 19,
                        activeColor: const Color(0xFFFFD54F),
                        inactiveColor: Colors.white24,
                        onChanged: (val) => gameCtrl.setTargetScore(val.toInt()),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: Colors.white,
                        ),
                        onPressed:
                            currentTargetScore < 1000
                                ? () => gameCtrl.setTargetScore(
                                  currentTargetScore + 50,
                                )
                                : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // Continue Button
            CustomButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              textColor: gameCtrl.currentMood.backgroundColors.first,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameIntroScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(
    BuildContext context, {
    required int moodIndex,
    required bool isSelected,
    required double time,
    required GameController gameCtrl,
  }) {
    final mood = gameCtrl.moods[moodIndex];

    return GestureDetector(
      onTap: () => gameCtrl.selectMood(moodIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: 102.0,
        child: GlassCard(
          borderRadius: 20.0,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
          backgroundColor:
              isSelected
                  ? Colors.white.withAlpha(95)
                  : Colors.white.withAlpha(35),
          borderColor:
              isSelected
                  ? Colors.white.withAlpha(255)
                  : Colors.white.withAlpha(75),
          borderWidth: isSelected ? 2.2 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BubbleOrb(
                emoji: mood.emoji,
                size: 54.0,
                tintColor: mood.tintColor,
                time: time,
                phase: moodIndex.toDouble(),
              ),
              const SizedBox(height: 8.0),
              Text(
                mood.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3.0),
              Text(
                mood.subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
