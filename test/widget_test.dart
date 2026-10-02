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
    // At early score (10 points), speed increase should be subtle (< 5%), not frantic
    final speedAt10 = controller.currentSpeed;
    expect(speedAt10, greaterThan(initialSpeed));
    expect(speedAt10 / initialSpeed, lessThan(1.06)); // Less than 6% increase at 10 points!

    // Verify spawn pacing is comfortable
    expect(controller.currentSpawnIntervalMs, lessThanOrEqualTo(initialSpawn));
    expect(controller.currentSpawnIntervalMs, greaterThanOrEqualTo(1000));

    controller.stopGame();
  });
}
