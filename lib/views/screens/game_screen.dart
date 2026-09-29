import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import '../widgets/bubble_field.dart';
import '../widgets/game_header.dart';
import 'reward_screen.dart';

/// Active gameplay screen coordinating mini-games and game loops.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _navigatedToReward = false;

  @override
  void initState() {
    super.initState();
    // Launch game when view is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GameController>().startGame();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameCtrl = context.watch<GameController>();

    // Detect game over and transition to reward screen
    if (gameCtrl.isGameOver && !_navigatedToReward) {
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
          child: Stack(
            children: [
              // 1. Full-screen bubble arena — fills ENTIRE screen edge-to-edge,
              //    including behind the status bar, so bubbles slide behind the header
              const Positioned.fill(
                child: BubbleField(),
              ),

              // 2. Floating borderless top HUD with its own SafeArea so the HUD
              //    text respects device notch while BubbleField paints behind it
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: GameHeader(
                    onQuit: () => _showQuitDialog(context, gameCtrl),
                  ),
                ),
              ),

              // 3. Flash feedback text (+10 / Target Escaped / NEW TARGET)
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
