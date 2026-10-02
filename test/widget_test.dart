import 'package:flutter_test/flutter_test.dart';
import 'package:emojis_bubble_game/main.dart';
import 'package:emojis_bubble_game/controllers/game_controller.dart';

void main() {
  testWidgets('App loads welcome screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmojiBubbleApp());

    // Verify game title appears
    expect(find.text('Emoji Pop 4D'), findsOneWidget);
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
}
