import 'package:flutter/material.dart';
import '../widgets/bubble_orb.dart';
import '../widgets/mood_scaffold.dart';
import 'welcome_screen.dart';

/// Minimal, seamless Splash Screen displaying only the logo in the bubble
/// and an iridescent loading bar on the same mood background as WelcomeScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _wobbleController;
  late final AnimationController _pulseController;
  late final AnimationController _progressController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // 1. Gentle entrance scale & fade
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeIn,
    );

    _introController.forward();

    // 2. Continuous 3D wobble matching WelcomeScreen
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // 3. Subtle aura pulse behind the bubble
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 4. Loading progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _progressController.forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _proceedToWelcome();
      }
    });
  }

  void _proceedToWelcome() {
    if (_navigated || !mounted) return;
    _navigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _wobbleController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _proceedToWelcome,
      child: MoodScaffold(
        scrollable: false,
        showFloatingBackground: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final double availableHeight = constraints.maxHeight;
            final double shortestSide = constraints.biggest.shortestSide;

            // Dynamically scale bubble size to fit nicely in portrait, landscape, tablets, and compact screens
            final double maxByHeight =
                (availableHeight * 0.46).clamp(80.0, 220.0);
            final double rawBubbleSize =
                (shortestSide * 0.42).clamp(90.0, 220.0);
            final double bubbleSize =
                rawBubbleSize > maxByHeight ? maxByHeight : rawBubbleSize;

            // Proportional aura sizing and pulsing
            final double auraBase = bubbleSize * 1.06;
            final double auraPulseMax = bubbleSize * 0.15;

            // Proportional progress bar width & height
            final double progressBarWidth =
                (bubbleSize * 1.25).clamp(130.0, 280.0);
            final double progressBarHeight =
                (bubbleSize * 0.042).clamp(5.0, 8.0);

            // Responsive vertical spacing & horizontal padding
            final double verticalSpacing =
                (availableHeight * 0.05).clamp(16.0, 48.0);
            final double horizontalPadding =
                (availableWidth * 0.06).clamp(16.0, 36.0);

            return Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hero 4D Bubble Orb with App Logo
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _wobbleController,
                          _pulseController,
                        ]),
                        builder: (context, _) {
                          final double pulse = _pulseController.value;
                          final double auraSize =
                              auraBase + (pulse * auraPulseMax);

                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Soft glowing aura matching bubble color
                                  Container(
                                    width: auraSize,
                                    height: auraSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFD54F)
                                              .withAlpha(
                                                (70 + (pulse * 40)).toInt(),
                                              ),
                                          blurRadius:
                                              (bubbleSize * 0.24) +
                                              (pulse * 15.0),
                                          spreadRadius:
                                              (bubbleSize * 0.024) +
                                              (pulse * 6.0),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // The Bubble with Logo inside
                                  BubbleOrb(
                                    imageAsset: 'assets/icon/app_icon_1024.png',
                                    size: bubbleSize,
                                    tintColor: const Color(0xFFFFD54F),
                                    time: _wobbleController.value * 10.0,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: verticalSpacing),

                      // Sleek Iridescent Loading Bar (No Text)
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          final double progress = _progressController.value;

                          return Container(
                            width: progressBarWidth,
                            height: progressBarHeight,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(40),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: progressBarWidth * progress,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD54F),
                                    Color(0xFFFF7E5F),
                                    Color(0xFFFEB47B),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD54F).withAlpha(150),
                                    blurRadius: 10.0,
                                    spreadRadius: 1.5,
                                  ),
                                ],
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
          },
        ),
      ),
    );
  }
}
