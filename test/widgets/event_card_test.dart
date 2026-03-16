import 'package:elapsed/models/event_model.dart';
import 'package:elapsed/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpCard(
  WidgetTester tester, {
  required Duration elapsed,
  required String format,
}) async {
  final event = EventModel(
    id: 'event-1',
    title: 'No Smoking',
    startDateTime: DateTime(2024, 1, 1),
    colorHex: '#29B6F6',
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ReorderableListView.builder(
          itemCount: 1,
          onReorder: (_, _) {},
          itemBuilder: (_, index) => EventCard(
            key: ValueKey(event.id),
            event: event,
            elapsed: elapsed,
            index: index,
            timeFormat: format,
            onTap: () {},
            onLongPress: () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('EventCard elapsed formatting', () {
    testWidgets('formats as days with clock by default', (tester) async {
      await _pumpCard(
        tester,
        elapsed: const Duration(days: 1, hours: 2, minutes: 3, seconds: 4),
        format: 'Days',
      );

      expect(find.text('1d 02:03:04'), findsOneWidget);
    });

    testWidgets('formats years', (tester) async {
      await _pumpCard(
        tester,
        elapsed: const Duration(days: 800),
        format: 'Years',
      );

      expect(find.text('2y 70d'), findsOneWidget);
    });

    testWidgets('formats months', (tester) async {
      await _pumpCard(
        tester,
        elapsed: const Duration(days: 65),
        format: 'Months',
      );

      expect(find.text('2m 5d'), findsOneWidget);
    });

    testWidgets('formats weeks', (tester) async {
      await _pumpCard(
        tester,
        elapsed: const Duration(days: 19),
        format: 'Weeks',
      );

      expect(find.text('2w 5d'), findsOneWidget);
    });

    testWidgets('formats hours, minutes and seconds', (tester) async {
      await _pumpCard(
        tester,
        elapsed: const Duration(hours: 5, minutes: 6, seconds: 7),
        format: 'Hours, minutes and seconds',
      );

      expect(find.text('05:06:07'), findsOneWidget);
    });
  });
}
