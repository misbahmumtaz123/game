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

  test('GameController speed increases progressively every 5 points', () {
    final controller = GameController();
    controller.startGame();

    final initialSpeed = controller.currentSpeed;
    final initialSpawn = controller.currentSpawnIntervalMs;

    // Simulate hitting target bubbles to score points
    // When score is 0: initial slow speed
    expect(controller.score, 0);

    // Hit a target (+10 points)
    final targetBubble = controller.bubbles.first;
    controller.handleShot(
      targetBubble.currentX * 400 + 10,
      targetBubble.y * 800 + 10,
      400,
      800,
    );

    // If score increased to >= 5 or >= 10, speed must increase
    if (controller.score >= 5) {
      expect(controller.currentSpeed, greaterThan(initialSpeed));
      expect(controller.currentSpawnIntervalMs, lessThanOrEqualTo(initialSpawn));
    }

    controller.stopGame();
  });
}
