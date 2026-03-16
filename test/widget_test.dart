import 'package:flutter_test/flutter_test.dart';
import 'package:elapsed/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ElapsedApp());
    await tester.pumpAndSettle();

    expect(find.text('Elapsed'), findsAtLeastNWidgets(1));
  });
}
