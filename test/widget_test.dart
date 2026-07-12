import 'package:flutter_test/flutter_test.dart';
import 'package:md_score/app.dart';

void main() {
  testWidgets('MD Score home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MDScoreApp());

    expect(find.text('MD Score'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
