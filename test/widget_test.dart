import 'package:flutter_test/flutter_test.dart';
import 'package:elapsed/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ElapsedApp());
    expect(find.text('Time Since'), findsOneWidget);
  });
}
