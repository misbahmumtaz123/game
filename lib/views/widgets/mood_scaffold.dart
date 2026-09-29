import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import 'floating_background.dart';

/// Common Scaffold with mood-based animated gradient and floating background.
class MoodScaffold extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final bool showFloatingBackground;
  final PreferredSizeWidget? appBar;

  const MoodScaffold({
    super.key,
    required this.child,
    this.scrollable = true,
    this.showFloatingBackground = true,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final gameCtrl = context.watch<GameController>();
    final backgroundColors = gameCtrl.currentMood.backgroundColors;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundColors,
          ),
        ),
        child: Stack(
          children: [
            if (showFloatingBackground) const FloatingBackground(),
            SafeArea(
              child:
                  scrollable
                      ? Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: SizedBox(
                            width: double.infinity,
                            child: child,
                          ),
                        ),
                      )
                      : child,
            ),
          ],
        ),
      ),
    );
  }
}
