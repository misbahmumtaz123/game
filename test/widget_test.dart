import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:emojis_bubble_game/main.dart';
import 'package:emojis_bubble_game/controllers/game_controller.dart';
import 'package:emojis_bubble_game/views/screens/game_screen.dart';
import 'package:emojis_bubble_game/views/screens/mood_selection_screen.dart';
import 'package:emojis_bubble_game/views/screens/game_intro_screen.dart';
import 'package:emojis_bubble_game/views/screens/reward_screen.dart';
import 'package:emojis_bubble_game/views/screens/smile_screen.dart';
import 'package:emojis_bubble_game/views/widgets/bubble_orb.dart';
import 'package:emojis_bubble_game/views/widgets/game_header.dart';
import 'package:emojis_bubble_game/services/tutorial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App loads splash screen and transitions to welcome screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmojiBubbleApp());

    // Verify splash screen has logo in bubble and no text widgets
    expect(find.byType(BubbleOrb), findsWidgets);
    expect(find.byType(Text), findsNothing);

    // Tap to skip splash screen and proceed to Welcome Screen
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify Welcome Screen appears with Start Game button and Title
    expect(find.text('Mood Switcher'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
  });

  test('GameController speed increases progressively and smoothly without harsh jumps', () {
    final controller = GameController();
    controller.startGame();

    final initialSpeed = controller.currentSpeed;
    final initialSpawn = controller.currentSpawnIntervalMs;

    // Simulate hitting target bubbles to score points
    expect(controller.score, 0);

    // Hit a target (+10 points)
    final targetBubble = controller.bubbles.first;
    controller.handleShot(
      targetBubble.currentX * 400 + 10,
      targetBubble.y * 800 + 10,
      400,
      800,
    );

    // Score is now 10
    expect(controller.score, 10);
    // At early score (10 points), speed increase should be gentle (< 10%), adhering to the 10% game design rule
    final speedAt10 = controller.currentSpeed;
    expect(speedAt10, greaterThan(initialSpeed));
    expect(speedAt10 / initialSpeed, lessThan(1.10));

    // Verify spawn pacing is comfortable
    expect(controller.currentSpawnIntervalMs, lessThanOrEqualTo(initialSpawn));
    expect(controller.currentSpawnIntervalMs, greaterThanOrEqualTo(1000));

    controller.stopGame();
  });

  testWidgets('Reaching 150 target score wins the game immediately with goal achieved', (WidgetTester tester) async {
    final controller = GameController();
    controller.startGame();

    expect(controller.targetScore, 150);
    expect(controller.isGoalReached, isFalse);

    // Hit targets until reaching 150
    while (controller.score < 150 && controller.isPlaying) {
      if (controller.bubbles.isEmpty) {
        await tester.pump(const Duration(milliseconds: 1100));
      }
      if (controller.bubbles.isEmpty) break;

      final target = controller.bubbles.firstWhere(
        (b) => b.emoji == controller.currentTargetEmoji,
        orElse: () => controller.bubbles.first,
      );
      controller.handleShot(
        target.currentX * 400 + 10,
        target.y * 800 + 10,
        400,
        800,
      );
      await tester.pump(const Duration(milliseconds: 600));
    }

    expect(controller.score, greaterThanOrEqualTo(150));
    expect(controller.isGoalReached, isTrue);
    expect(controller.isGameOver, isTrue);
    expect(controller.isPlaying, isFalse);

    controller.stopGame();
  });

  testWidgets('GameScreen transitions to RewardScreen on game over and Play Again works properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = GameController();

    await tester.pumpWidget(
      ChangeNotifierProvider<GameController>.value(
        value: controller,
        child: const MaterialApp(
          home: GameScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Now in GameScreen
    expect(find.textContaining('TARGET:'), findsOneWidget);
    // Verify 3 lives hearts are present and no "HP" or "50/50" text is shown
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
    expect(find.textContaining('HP'), findsNothing);
    expect(find.textContaining('50/50'), findsNothing);

    // Score enough to win by hitting target bubble
    controller.setTargetScore(10);
    final targetBubble = controller.bubbles.firstWhere(
      (b) => b.emoji == controller.currentTargetEmoji,
    );
    controller.handleBubbleTap(targetBubble, 400, 800);

    // Advance frames for transition to RewardScreen
    await tester.pump();
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Now on RewardScreen
    expect(find.text('🎉 Play Again!'), findsOneWidget);

    // Tap Play Again
    await tester.tap(find.text('🎉 Play Again!'));
    await tester.pump();
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Should successfully be back in GameScreen, NOT prematurely bounced to RewardScreen
    expect(find.textContaining('TARGET:'), findsOneWidget);
    expect(find.text('🎉 Play Again!'), findsNothing);

    controller.stopGame();
  });

  testWidgets('MoodSelectionScreen displays all 5 mood containers in a single responsive row', (WidgetTester tester) async {
    // Test on a narrow mobile viewport
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = GameController();

    await tester.pumpWidget(
      ChangeNotifierProvider<GameController>.value(
        value: controller,
        child: const MaterialApp(
          home: MoodSelectionScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify all 5 moods are present
    expect(find.text('Sad'), findsOneWidget);
    expect(find.text('Angry'), findsOneWidget);
    expect(find.text('Anxious'), findsOneWidget);
    expect(find.text('Tired'), findsOneWidget);
    expect(find.text('Lonely'), findsOneWidget);

    // Verify all 5 mood card centers share the same vertical Y coordinate (in one row)
    final sadCenter = tester.getCenter(find.text('Sad'));
    final angryCenter = tester.getCenter(find.text('Angry'));
    final anxiousCenter = tester.getCenter(find.text('Anxious'));
    final tiredCenter = tester.getCenter(find.text('Tired'));
    final lonelyCenter = tester.getCenter(find.text('Lonely'));

    expect(angryCenter.dy, closeTo(sadCenter.dy, 1.0));
    expect(anxiousCenter.dy, closeTo(sadCenter.dy, 1.0));
    expect(tiredCenter.dy, closeTo(sadCenter.dy, 1.0));
    expect(lonelyCenter.dy, closeTo(sadCenter.dy, 1.0));

    // Verify horizontal ordering from left to right
    expect(sadCenter.dx, lessThan(angryCenter.dx));
    expect(angryCenter.dx, lessThan(anxiousCenter.dx));
    expect(anxiousCenter.dx, lessThan(tiredCenter.dx));
    expect(tiredCenter.dx, lessThan(lonelyCenter.dx));

    // Tap Angry mood and check controller selection
    await tester.tap(find.text('Angry'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.currentMoodIndex, 1);
    expect(controller.currentMood.name, 'Angry');

    // Tap 250 goal preset chip and verify score update
    await tester.tap(find.text('250'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.targetScore, 250);
  });

  testWidgets('SplashScreen is responsive across compact mobile, landscape, and large tablet viewports', (WidgetTester tester) async {
    final sizes = [
      const Size(320, 480),   // Compact mobile
      const Size(800, 360),   // Landscape mobile
      const Size(1024, 1366), // Large tablet
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const EmojiBubbleApp());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(BubbleOrb), findsWidgets);
      expect(find.byType(Text), findsNothing);

      // Verify no overflow errors occurred
      expect(tester.takeException(), isNull);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('GameIntroScreen displays aligned instructions and is fixed and non-scrollable without overflow', (WidgetTester tester) async {
    final sizes = [
      const Size(400, 900),
      const Size(360, 640),
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      final controller = GameController();

      await tester.pumpWidget(
        ChangeNotifierProvider<GameController>.value(
          value: controller,
          child: const MaterialApp(
            home: GameIntroScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));

      // Verify no SingleChildScrollView (screen is fixed and not scrollable)
      expect(find.byType(SingleChildScrollView), findsNothing);

      // Verify all 4 instructions and values exist
      expect(find.text('Hit Target'), findsOneWidget);
      expect(find.text('+10 points'), findsOneWidget);

      expect(find.text('Missing Target'), findsOneWidget);
      expect(find.text('-3 points'), findsOneWidget);

      expect(find.text('Wrong Hit'), findsOneWidget);
      expect(find.text('-1 life'), findsOneWidget);

      expect(find.text('Total Lives'), findsOneWidget);
      expect(find.text('3 lives'), findsOneWidget);

      // Verify horizontal alignment: left titles should align vertically
      final hitCenter = tester.getTopLeft(find.text('Hit Target'));
      final missingCenter = tester.getTopLeft(find.text('Missing Target'));
      final wrongCenter = tester.getTopLeft(find.text('Wrong Hit'));
      final livesCenter = tester.getTopLeft(find.text('Total Lives'));

      expect(missingCenter.dx, equals(hitCenter.dx));
      expect(wrongCenter.dx, equals(hitCenter.dx));
      expect(livesCenter.dx, equals(hitCenter.dx));

      // Verify no RenderFlex overflow
      expect(tester.takeException(), isNull);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('RewardScreen is responsive and unboxes gift with quote/joke popups and theme changes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = GameController();
    controller.startGame();
    controller.setTargetScore(10);
    final targetBubble = controller.bubbles.firstWhere(
      (b) => b.emoji == controller.currentTargetEmoji,
    );
    controller.handleBubbleTap(targetBubble, 400, 800);

    await tester.pumpWidget(
      ChangeNotifierProvider<GameController>.value(
        value: controller,
        child: const MaterialApp(
          home: RewardScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify single-line mood transformation banner is displayed
    expect(find.textContaining('Mood Transformed to Happy!'), findsOneWidget);

    // 2. Verify Gift Box is initial state
    expect(find.text('Tap Gift Box to Open! ✨'), findsOneWidget);

    // 3. Tap Gift Box to unbox
    await tester.tap(find.text('Tap Gift Box to Open! ✨'));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Quote and Joke cards are now revealed
    expect(find.text('Inspiring Quote'), findsOneWidget);
    expect(find.text('Cheer-Up Joke'), findsOneWidget);

    // 4. Tap Quote card to open Quote Popup
    await tester.tap(find.text('Inspiring Quote'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('✨ Inspiring Quote ✨'), findsOneWidget);
    // Dismiss popup - navigates to SmileScreen with smile emoji and "Please smile"
    await tester.tap(find.text('Awesome! ✨'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    // Verify SmileScreen displays big smile emoji and "Please smile", and has NO back button
    expect(find.text('Please smile'), findsOneWidget);
    expect(find.text('😊'), findsWidgets);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
    // Tap anywhere to pop bubble and return back to RewardScreen
    await tester.tap(find.text('Please smile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Please smile'), findsNothing);
    // Verify "Please smile (tap to view)" banner is removed from RewardScreen
    expect(find.textContaining('Tap to view'), findsNothing);

    // 5. Tap Joke card to open Joke Popup
    await tester.tap(find.text('Cheer-Up Joke'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('🎭 Cheer-Up Joke 🎭'), findsOneWidget);
    // Dismiss popup - navigates to SmileScreen with laugh emoji and "Please laugh"
    await tester.tap(find.text('Haha, Love it! 😆'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    // Verify SmileScreen displays big laugh emoji and "Please laugh", and has NO back button
    expect(find.text('Please laugh'), findsOneWidget);
    expect(find.text('😂'), findsWidgets);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
    // Hit / tap emoji to pop bubble and return back to RewardScreen
    await tester.tap(find.text('Please laugh'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Please laugh'), findsNothing);
    // 6. Tap smiley on the reward page to open inspiring quote screen (stays until emoji is hit, no loading bar)
    await tester.tap(find.byType(BubbleOrb), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('I know life is hard'), findsOneWidget);
    expect(find.textContaining('Belive Yourself'), findsOneWidget);
    // Verify no loading/countdown progress bar exists
    expect(find.byType(FractionallySizedBox), findsNothing);
    // Hit / tap the emoji to pop bubble and return to RewardScreen
    await tester.tap(find.textContaining('I know life is hard'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('I know life is hard'), findsNothing);

    // 7. Test 3-color Theme Switcher (Ocean is default)
    expect(find.text('Violet'), findsOneWidget);
    await tester.tap(find.text('Violet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Emerald'), findsOneWidget);
    await tester.tap(find.text('Emerald'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Play Again button exists
    expect(find.text('🎉 Play Again!'), findsOneWidget);

    // Verify no exception occurred
    expect(tester.takeException(), isNull);
  });

  testWidgets('SmileScreen is responsive on fling and across screen sizes', (WidgetTester tester) async {
    // 1. Test responsive sizing on compact landscape viewport
    tester.view.physicalSize = const Size(700, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SmileScreen(
          emoji: '😊',
          text: 'I know life is hard, but face every challenge with a smile.\nBelive Yourself',
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify rendered without overflow
    expect(find.textContaining('I know life is hard'), findsOneWidget);
    expect(find.textContaining('Belive Yourself'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 2. Test fling / swipe gesture responsiveness - flinging pops bubble
    await tester.fling(find.byType(SmileScreen), const Offset(0, -250), 800.0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // Pop animation triggers without errors
    expect(tester.takeException(), isNull);
  });

  testWidgets('GameHeader in GameScreen renders without overflow on compact 360px and 320px screens', (WidgetTester tester) async {
    // Test on 360px standard Android width
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = GameController();
    await tester.pumpWidget(
      ChangeNotifierProvider<GameController>.value(
        value: controller,
        child: const MaterialApp(
          home: GameScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify all header items are visible and zero overflow occurs
    expect(find.textContaining('TARGET:'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.stars_rounded), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Test on ultra-compact 320px width
    tester.view.physicalSize = const Size(320, 640);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('TARGET:'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.stopGame();
  });

  testWidgets('Target is prominent in top bar GameHeader and tutorial persists on 1st use', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Verify initially tutorial is not marked seen
    expect(await TutorialService.hasSeenTutorial(), isFalse);

    final controller = GameController();
    await tester.pumpWidget(
      ChangeNotifierProvider<GameController>.value(
        value: controller,
        child: const MaterialApp(
          home: GameScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // 1. Verify Target is rendered prominently in top bar GameHeader
    expect(find.byType(GameHeader), findsOneWidget);
    expect(find.textContaining('TARGET:'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.stars_rounded), findsOneWidget);

    // 2. Mark tutorial as completed
    await TutorialService.markTutorialSeen();
    expect(await TutorialService.hasSeenTutorial(), isTrue);

    // 3. Reset tutorial
    await TutorialService.resetTutorial();
    expect(await TutorialService.hasSeenTutorial(), isFalse);

    controller.stopGame();
    await tester.pumpWidget(const SizedBox());
  });
}


