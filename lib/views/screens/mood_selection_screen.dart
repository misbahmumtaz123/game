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
    final selectedMood = gameCtrl.currentMood;
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Select Your Starting Mood',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
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
                ),
                const SizedBox(height: 6.0),
                const Text(
                  'Pop away the negativity to reach the Happy Mood!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18.0),

                // 5 Emojis Container in Exactly One Responsive Row
                AnimatedBuilder(
                  animation: _wobbleController,
                  builder: (context, _) {
                    final time = _wobbleController.value * 12.0;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;
                        const spacing = 6.0;
                        final itemWidth =
                            (availableWidth - (spacing * (moods.length - 1))) /
                            moods.length;
                        final orbSize =
                            (itemWidth * 0.58).clamp(32.0, 52.0);

                        return Column(
                          children: [
                            Row(
                              children: [
                                for (int i = 0; i < moods.length; i++) ...[
                                  if (i > 0) const SizedBox(width: spacing),
                                  Expanded(
                                    child: _buildMoodCard(
                                      context,
                                      moodIndex: i,
                                      isSelected: selectedMoodIndex == i,
                                      time: time,
                                      gameCtrl: gameCtrl,
                                      orbSize: orbSize,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12.0),

                            // Selected Mood Detail Spotlight
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Container(
                                key: ValueKey(selectedMood.name),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 9.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: selectedMood.tintColor.withAlpha(180),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${selectedMood.emoji} ${selectedMood.name}: ',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        selectedMood.subtitle,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20.0),

                // Target Score Goal Selector Card
                GlassCard(
                  borderRadius: 22.0,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '🎯 Goal for Happy Mood: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
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
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'What score will transform your mood to Happy? 😊',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                      const SizedBox(height: 12.0),

                      // Quick Preset Chips
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 6.0,
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
                                  fontSize: 13.0,
                                ),
                              ),
                              selected: currentTargetScore == preset,
                              selectedColor: const Color(0xFFFFD54F),
                              backgroundColor: Colors.white.withAlpha(30),
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              onSelected: (_) => gameCtrl.setTargetScore(preset),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6.0),

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
                          Expanded(
                            child: Slider(
                              value: currentTargetScore
                                  .toDouble()
                                  .clamp(50.0, 1000.0),
                              min: 50.0,
                              max: 1000.0,
                              divisions: 19,
                              activeColor: const Color(0xFFFFD54F),
                              inactiveColor: Colors.white24,
                              onChanged: (val) =>
                                  gameCtrl.setTargetScore(val.toInt()),
                            ),
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

                const SizedBox(height: 20.0),

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
                const SizedBox(height: 12.0),
              ],
            ),
          ),
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
    required double orbSize,
  }) {
    final mood = gameCtrl.moods[moodIndex];

    return GestureDetector(
      onTap: () => gameCtrl.selectMood(moodIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3.0),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.white.withAlpha(85)
                  : Colors.white.withAlpha(28),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color:
                isSelected
                    ? Colors.white
                    : Colors.white.withAlpha(60),
            width: isSelected ? 2.2 : 1.0,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: mood.tintColor.withAlpha(140),
                      blurRadius: 10.0,
                      spreadRadius: 1.0,
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BubbleOrb(
              emoji: mood.emoji,
              size: orbSize,
              tintColor: mood.tintColor,
              time: time,
              phase: moodIndex.toDouble(),
            ),
            const SizedBox(height: 6.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                mood.name,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.0,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  shadows: isSelected
                      ? const [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Container(
              width: 5.0,
              height: 5.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? const Color(0xFFFFD54F) : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
