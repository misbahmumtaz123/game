import 'package:flutter_test/flutter_test.dart';
import 'package:emojis_bubble_game/main.dart';

void main() {
  testWidgets('App loads welcome screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmojiBubbleApp());

    // Verify game title appears
    expect(find.text('Emoji Pop 4D'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
  });
}
