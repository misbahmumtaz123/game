import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import '../../models/mood_model.dart';
import '../widgets/bubble_orb.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import 'game_screen.dart';
import 'mood_selection_screen.dart';
import 'smile_screen.dart';

/// Responsive Reward Screen with suspenseful single-line mood transformation,
/// interactive unboxing Gift Box, Quote & Joke pop-ups, and a 3-color app theme switcher.
class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _giftWobbleController;

  bool _isGiftOpened = false;
  int _selectedThemeIndex = 2; // Default theme: Ocean

  // App-aligned 3-color theme palettes (derived from app themes)
  static const List<List<Color>> _appThemes = [
    // Theme 1: Emerald Joy (App Happy theme)
    [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF10B981)],
    // Theme 2: Cosmic Violet (App Anxious/Peace theme)
    [Color(0xFF1E1035), Color(0xFF4C1D95), Color(0xFF8B5CF6)],
    // Theme 3: Ocean Sunshine (App Sad/Uplift theme)
    [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF38BDF8)],
  ];

  static const List<String> _themeLabels = ['Emerald', 'Violet', 'Ocean'];

  // Frozen snapshot at game-end
  late final bool _isWon;
  late final HappyRewardItem _reward;
  late final MoodModel _fromMood;
  late final int _finalScore;
  late final int _finalTargetScore;
  late final int _finalLives;
  late final Color _tintColor;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _giftWobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    final gameCtrl = context.read<GameController>();
    _isWon = gameCtrl.isGoalReached || gameCtrl.score >= gameCtrl.targetScore;
    _reward = gameCtrl.currentReward;
    _fromMood = gameCtrl.currentMood;
    _finalScore = gameCtrl.score;
    _finalTargetScore = gameCtrl.targetScore;
    _finalLives = gameCtrl.lives;
    _tintColor = gameCtrl.currentMood.tintColor;

    // Default theme is Ocean (Theme index 2)
    _selectedThemeIndex = 2;
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _giftWobbleController.dispose();
    super.dispose();
  }

  void _showQuotePopup(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: GlassCard(
          borderRadius: 28.0,
          backgroundColor: const Color(0xFF0F172A).withAlpha(235),
          borderColor: const Color(0xFF38BDF8).withAlpha(140),
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58.0,
                height: 58.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withAlpha(45),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.8),
                ),
                child: const Text('📜', style: TextStyle(fontSize: 28.0)),
              ),
              const SizedBox(height: 12.0),
              const Text(
                '✨ Inspiring Quote ✨',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 14.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(22),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.white.withAlpha(45)),
                ),
                child: Column(
                  children: [
                    Text(
                      '“${_reward.quote}”',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '— ${_reward.author}',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18.0),
              CustomButton(
                label: 'Awesome! ✨',
                icon: Icons.sentiment_very_satisfied_rounded,
                textColor: const Color(0xFF0F172A),
                fontSize: 15.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26.0,
                  vertical: 11.0,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SmileScreen(
                        emoji: '😊',
                        text: 'Please smile',
                        backgroundColors: _appThemes[_selectedThemeIndex],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJokePopup(BuildContext context) {
    HapticFeedback.lightImpact();
    bool punchlineRevealed = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: GlassCard(
            borderRadius: 28.0,
            backgroundColor: const Color(0xFF0F172A).withAlpha(235),
            borderColor: const Color(0xFFFBBF24).withAlpha(140),
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58.0,
                  height: 58.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withAlpha(45),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFBBF24), width: 1.8),
                  ),
                  child: const Text('😂', style: TextStyle(fontSize: 28.0)),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  '🎭 Cheer-Up Joke 🎭',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 14.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(22),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.white.withAlpha(45)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _reward.jokeQuestion,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      if (punchlineRevealed)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD54F).withAlpha(230),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Text(
                            _reward.jokePunchline,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      else
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withAlpha(45),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setDialogState(() => punchlineRevealed = true);
                          },
                          icon: const Icon(
                            Icons.touch_app_rounded,
                            color: Colors.white,
                            size: 18.0,
                          ),
                          label: const Text(
                            'Tap to reveal punchline! 😄',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18.0),
                CustomButton(
                  label: 'Haha, Love it! 😆',
                  icon: Icons.sentiment_very_satisfied_rounded,
                  textColor: const Color(0xFF0F172A),
                  fontSize: 15.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26.0,
                    vertical: 11.0,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SmileScreen(
                          emoji: '😂',
                          text: 'Please laugh',
                          backgroundColors: _appThemes[_selectedThemeIndex],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSmileScreenWithLifeQuote(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmileScreen(
          emoji: '😊',
          text:
              'I know life is hard, but face every challenge with a smile.\nBelive Yourself',
          displayDuration: null, // Stays until the emoji is hit
          backgroundColors: _appThemes[_selectedThemeIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _appThemes[_selectedThemeIndex],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double heroSize =
                  (constraints.biggest.shortestSide * 0.28).clamp(80.0, 130.0);

              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top Theme Selector: 3 colors according to app theme
                        _buildThemeSelector(),

                        const SizedBox(height: 12.0),

                        // Title Header
                        Text(
                          _isWon
                              ? '🌟 MOOD TRANSFORMED! 🌟'
                              : (_finalLives <= 0
                                  ? '💔 ALL LIVES LOST'
                                  : '⏱️ TIME\'S UP'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),

                        const SizedBox(height: 10.0),

                        // Suspensive One-Line Mood Transformation
                        _buildOneLineMoodTransformation(),

                        const SizedBox(height: 14.0),

                        // Hero Orb Indicator (Tap smiley to view 5-second inspiring message)
                        GestureDetector(
                          onTap: () => _openSmileScreenWithLifeQuote(context),
                          child: AnimatedBuilder(
                            animation: _bounceController,
                            builder: (context, _) {
                              return BubbleOrb(
                                emoji: _isWon
                                    ? '😊'
                                    : (_finalLives <= 0 ? '💔' : '⌛'),
                                size: heroSize,
                                tintColor:
                                    _isWon ? const Color(0xFFFFD54F) : _tintColor,
                                time: _bounceController.value * 4.0,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10.0),

                        // Score Recap Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: Colors.white.withAlpha(100),
                            ),
                          ),
                          child: Text(
                            'Score: $_finalScore / Goal: $_finalTargetScore pts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        // -------------------------------------------------------------
                        // GIFT BOX REWARD SECTION
                        // -------------------------------------------------------------
                        if (_isWon)
                          _buildGiftBoxSection(context)
                        else
                          // Locked Reward Card
                          GlassCard(
                            borderRadius: 20.0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18.0,
                              vertical: 16.0,
                            ),
                            backgroundColor: Colors.white.withAlpha(30),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: Color(0xFFFFD54F),
                                  size: 22.0,
                                ),
                                SizedBox(width: 8.0),
                                Flexible(
                                  child: Text(
                                    'Gift Box Locked (Score target to open!)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20.0),

                        // Play Again Action Button
                        CustomButton(
                          label: _isWon ? '🎉 Play Again!' : '🔥 Try Again!',
                          icon: Icons.replay_rounded,
                          textColor: _appThemes[_selectedThemeIndex].first,
                          fontSize: 17.5,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26.0,
                            vertical: 13.0,
                          ),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8.0),

                        // Change Bad Mood navigation
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MoodSelectionScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 16.0,
                            ),
                            child: Text(
                              'Change Bad Mood',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
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
              );
            },
          ),
        ),
      ),
    );
  }

  /// Theme Switcher Pill (changes screen into 3 app-matching themes)
  Widget _buildThemeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(50),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.white.withAlpha(35)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.palette_outlined, color: Colors.white70, size: 15.0),
            const SizedBox(width: 6.0),
            for (int i = 0; i < 3; i++) ...[
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedThemeIndex = i);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7.0,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedThemeIndex == i
                        ? Colors.white.withAlpha(60)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: _selectedThemeIndex == i
                          ? Colors.white
                          : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9.0,
                        height: 9.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _appThemes[i][2],
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _themeLabels[i],
                        style: TextStyle(
                          color: _selectedThemeIndex == i
                              ? Colors.white
                              : Colors.white70,
                          fontSize: 11.0,
                          fontWeight: _selectedThemeIndex == i
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Suspenseful Mood Transformation in a single line
  Widget _buildOneLineMoodTransformation() {
    if (_isWon) {
      return GestureDetector(
        onTap: () => _openSmileScreenWithLifeQuote(context),
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(28),
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: Colors.white.withAlpha(65), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD54F).withAlpha(50),
              blurRadius: 16.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_fromMood.emoji} ${_fromMood.name}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFFFD54F),
                  size: 15.0,
                ),
              ),
              const Flexible(
                child: Text(
                  'Mood Transformed to Happy! 😊',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: Colors.white.withAlpha(40), width: 1.0),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_fromMood.emoji} ${_fromMood.name}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white38,
                  size: 14.0,
                ),
              ),
              const Flexible(
                child: Text(
                  'Transformation Pending 🎯',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Gift Box Section with Suspenseful Unboxing & Revealed Quote & Joke
  Widget _buildGiftBoxSection(BuildContext context) {
    if (!_isGiftOpened) {
      // Unopened Mystery Gift Box with Wobble & Glowing Aura
      return GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() => _isGiftOpened = true);
        },
        child: AnimatedBuilder(
          animation: _giftWobbleController,
          builder: (context, _) {
            final wobble = sin(_giftWobbleController.value * 2.0 * pi) * 0.08;
            final pulse =
                (sin(_giftWobbleController.value * 2.0 * pi) + 1.0) / 2.0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: wobble,
                  child: Container(
                    width: 110.0,
                    height: 110.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFFEF08A),
                          Color(0xFFF59E0B),
                          Color(0xFFD97706),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B)
                              .withAlpha((90 + (pulse * 90)).toInt()),
                          blurRadius: 26.0 + (pulse * 12.0),
                          spreadRadius: 3.0 + (pulse * 3.0),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('🎁', style: TextStyle(fontSize: 56.0)),
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(45),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.white.withAlpha(120),
                      width: 1.2,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: Color(0xFFFFD54F),
                        size: 16.0,
                      ),
                      SizedBox(width: 5.0),
                      Flexible(
                        child: Text(
                          'Tap Gift Box to Open! ✨',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Opened Gift Box displaying Quote and Joke options
    return GlassCard(
      borderRadius: 22.0,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      backgroundColor: Colors.white.withAlpha(40),
      borderColor: Colors.white.withAlpha(70),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🎁 ', style: TextStyle(fontSize: 18.0)),
              const Expanded(
                child: Text(
                  'Gift Box Opened! Tap to View:',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white70,
                  size: 19.0,
                ),
                tooltip: 'Close Gift Box',
                onPressed: () => setState(() => _isGiftOpened = false),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // 1. Quote Item Card (triggers Quote Popup)
          _buildRewardItemCard(
            icon: Icons.format_quote_rounded,
            emoji: '📜',
            title: 'Inspiring Quote',
            subtitle: 'Tap to read wisdom & inspiration',
            badgeText: 'READ ✨',
            color: const Color(0xFF38BDF8),
            onTap: () => _showQuotePopup(context),
          ),

          const SizedBox(height: 8.0),

          // 2. Joke Item Card (triggers Joke Popup)
          _buildRewardItemCard(
            icon: Icons.sentiment_very_satisfied_rounded,
            emoji: '😂',
            title: 'Cheer-Up Joke',
            subtitle: 'Tap for an instant smile & chuckle',
            badgeText: 'LAUGH 🎭',
            color: const Color(0xFFFBBF24),
            onTap: () => _showJokePopup(context),
          ),
        ],
      ),
    );
  }

  /// Aligned Reward Item Card
  Widget _buildRewardItemCard({
    required IconData icon,
    required String emoji,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(24),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: color.withAlpha(140), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(35),
              blurRadius: 10.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withAlpha(45),
                shape: BoxShape.circle,
                border: Border.all(color: color.withAlpha(180), width: 1.5),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 18.0)),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9.0,
                vertical: 4.5,
              ),
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: color.withAlpha(180), width: 1.2),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: color,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
