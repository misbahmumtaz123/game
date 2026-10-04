import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

/// Service managing the "How to Play" interactive onboarding tutorial.
/// Shows once upon initial app installation/use, saving state to SharedPreferences.
class TutorialService {
  static const String _prefKeyHasSeenTutorial = 'has_seen_game_tutorial';

  /// Check whether the user has already completed or skipped the tutorial.
  static Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyHasSeenTutorial) ?? false;
  }

  /// Mark the tutorial as completed.
  static Future<void> markTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyHasSeenTutorial, true);
  }

  /// Reset tutorial state (useful for replay / testing).
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyHasSeenTutorial);
  }

  /// Builds and starts the TutorialCoachMark walkthrough.
  static TutorialCoachMark createGameTutorial({
    required BuildContext context,
    required GlobalKey targetKey,
    required GlobalKey livesKey,
    required GlobalKey scoreTimerKey,
    required GlobalKey arenaKey,
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    final List<TargetFocus> targets = [
      // 1. Prominent Large Target Focus
      TargetFocus(
        identify: "target_banner_focus",
        keyTarget: targetKey,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withAlpha(240),
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: const Color(0xFFFFD54F).withAlpha(160),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withAlpha(50),
                      blurRadius: 16.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD54F).withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🎯', style: TextStyle(fontSize: 22.0)),
                        ),
                        const SizedBox(width: 10.0),
                        const Expanded(
                          child: Text(
                            'Active Target Emoji',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Hit the floating bubble with this emoji to score +10 Points! The target changes periodically, so keep your eyes on it.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Text(
                          'Next ➜',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // 2. Lives Indicator Focus
      TargetFocus(
        identify: "lives_focus",
        keyTarget: livesKey,
        shape: ShapeLightFocus.RRect,
        radius: 18,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withAlpha(240),
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: const Color(0xFFF43F5E).withAlpha(160),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF43F5E).withAlpha(50),
                      blurRadius: 16.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E).withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('❤️', style: TextStyle(fontSize: 22.0)),
                        ),
                        const SizedBox(width: 10.0),
                        const Expanded(
                          child: Text(
                            '3 Player Lives',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'You start with 3 lives. Hitting wrong distraction emojis damages you. Avoid wrong hits to protect your lives!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Text(
                          'Next ➜',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // 3. Score & Timer Focus
      TargetFocus(
        identify: "score_timer_focus",
        keyTarget: scoreTimerKey,
        shape: ShapeLightFocus.RRect,
        radius: 18,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withAlpha(240),
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withAlpha(160),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withAlpha(50),
                      blurRadius: 16.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('⏱️', style: TextStyle(fontSize: 22.0)),
                        ),
                        const SizedBox(width: 10.0),
                        const Expanded(
                          child: Text(
                            'Score & 60s Clock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Reach the 150 points goal before the 1-minute countdown runs out to transform your mood to Happy! Missing targets will deduct 3 points.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Text(
                          'Next ➜',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // 4. Arena Floating Bubbles Focus
      TargetFocus(
        identify: "arena_focus",
        keyTarget: arenaKey,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withAlpha(240),
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: const Color(0xFF10B981).withAlpha(160),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withAlpha(50),
                      blurRadius: 16.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🫧', style: TextStyle(fontSize: 22.0)),
                        ),
                        const SizedBox(width: 10.0),
                        const Expanded(
                          child: Text(
                            'Pop & Play!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Tap bubbles as they float upwards. Hit the target to score, avoid the rest, and have fun!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withAlpha(100),
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Let\'s Play! 🚀',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    return TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF030712),
      textSkip: "SKIP",
      textStyleSkip: const TextStyle(
        color: Color(0xFFFFD54F),
        fontSize: 15.0,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
      paddingFocus: 8.0,
      opacityShadow: 0.85,
      onFinish: () {
        markTutorialSeen();
        onFinish();
      },
      onSkip: () {
        markTutorialSeen();
        onSkip();
        return true;
      },
    );
  }
}
