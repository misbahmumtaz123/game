import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../controllers/game_controller.dart';
import '../../services/tutorial_service.dart';
import '../widgets/bubble_field.dart';
import '../widgets/game_header.dart';
import 'reward_screen.dart';

/// Active gameplay screen coordinating mini-games, game loops, target displays,
/// and the first-use How-to-Play tutorial coach mark.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _navigatedToReward = false;
  GameController? _gameCtrl;

  Timer? _tutorialTimer;

  // GlobalKeys for TutorialCoachMark target highlights
  final GlobalKey _targetKey = GlobalKey();
  final GlobalKey _livesKey = GlobalKey();
  final GlobalKey _scoreTimerKey = GlobalKey();
  final GlobalKey _arenaKey = GlobalKey();
  TutorialCoachMark? _tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctrl = context.read<GameController>();
      _gameCtrl = ctrl;
      ctrl.startGame();
      ctrl.addListener(_onGameChanged);

      _checkAndShowTutorial(ctrl);
    });
  }

  /// Automatically shows the "How to Play" tutorial on 1st use only
  Future<void> _checkAndShowTutorial(GameController ctrl) async {
    final bool hasSeen = await TutorialService.hasSeenTutorial();
    if (!hasSeen && mounted) {
      ctrl.pauseGame();

      // Short delay ensuring all widgets and GlobalKeys are completely laid out
      _tutorialTimer?.cancel();
      _tutorialTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _tutorialCoachMark = TutorialService.createGameTutorial(
          context: context,
          targetKey: _targetKey,
          livesKey: _livesKey,
          scoreTimerKey: _scoreTimerKey,
          arenaKey: _arenaKey,
          onFinish: () {
            if (mounted) {
              ctrl.resumeGame();
            }
          },
          onSkip: () {
            if (mounted) {
              ctrl.resumeGame();
            }
          },
        );
        _tutorialCoachMark?.show(context: context);
      });
    }
  }

  /// Allows re-running the how to play tutorial explicitly anytime
  void _showTutorialExplicitly() {
    final ctrl = _gameCtrl;
    if (ctrl == null || !mounted) return;
    ctrl.pauseGame();
    _tutorialCoachMark = TutorialService.createGameTutorial(
      context: context,
      targetKey: _targetKey,
      livesKey: _livesKey,
      scoreTimerKey: _scoreTimerKey,
      arenaKey: _arenaKey,
      onFinish: () {
        if (mounted) ctrl.resumeGame();
      },
      onSkip: () {
        if (mounted) ctrl.resumeGame();
      },
    );
    _tutorialCoachMark?.show(context: context);
  }

  @override
  void dispose() {
    _tutorialTimer?.cancel();
    _gameCtrl?.removeListener(_onGameChanged);
    super.dispose();
  }

  void _onGameChanged() {
    if (!mounted || _navigatedToReward) return;

    final ctrl = _gameCtrl;
    if (ctrl != null && ctrl.isGameOver) {
      _navigatedToReward = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, secondaryAnimation) =>
                  const RewardScreen(),
              transitionsBuilder: (_, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameCtrl = context.watch<GameController>();
    final mood = gameCtrl.currentMood;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<GameController>().stopGame();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: mood.backgroundColors,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    // 1. Top HUD Bar with Large Prominent Target, Lives, Score, Timer
                    GameHeader(
                      onQuit: () => _showQuitDialog(context, gameCtrl),
                      livesKey: _livesKey,
                      targetKey: _targetKey,
                      scoreTimerKey: _scoreTimerKey,
                      onHelpTap: _showTutorialExplicitly,
                    ),

                    // 3. AppBar boundary line separating header from the game arena
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withAlpha(0),
                            Colors.white.withAlpha(70),
                            Colors.white.withAlpha(0),
                          ],
                        ),
                      ),
                    ),

                    // 4. Play arena strictly below the boundary line
                    Expanded(
                      child: Container(
                        key: _arenaKey,
                        child: const ClipRect(
                          child: BubbleField(),
                        ),
                      ),
                    ),
                  ],
                ),

                // 5. Flash feedback text (+10 / Target Escaped / NEW TARGET)
                if (gameCtrl.flashFeedback.isNotEmpty)
                  IgnorePointer(
                    child: Center(
                      child: AnimatedScale(
                        scale: 1.05,
                        duration: const Duration(milliseconds: 150),
                        child: Text(
                          gameCtrl.flashFeedback,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: gameCtrl.flashFeedback.startsWith('-')
                                ? Colors.redAccent
                                : const Color(0xFFFFEB3B),
                            fontSize: 44.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            shadows: const [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 14,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuitDialog(BuildContext context, GameController gameCtrl) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Leave Game?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Your progress in this session will be lost.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Keep Playing',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  gameCtrl.stopGame();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Quit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
