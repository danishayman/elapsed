import 'package:elapsed/screens/add_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows validation when trying to save without date/time', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddEventScreen()));

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(find.text('Please select a date and time'), findsOneWidget);
  });

  testWidgets('start from now populates date and time label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddEventScreen()));

    final startFromNowFinder = find.text('or start from now');
    await tester.ensureVisible(startFromNowFinder);
    await tester.tap(startFromNowFinder);
    await tester.pumpAndSettle();

    expect(find.text('Event date & time'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data?.contains('/') ?? false) &&
            (widget.data?.contains('•') ?? false),
      ),
      findsOneWidget,
    );
  });
}
