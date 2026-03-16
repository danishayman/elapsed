import 'package:elapsed/models/event_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventModel', () {
    test('encodeList/decodeList round-trips all fields', () {
      final first = EventModel(
        id: '1',
        title: 'First',
        startDateTime: DateTime(2024, 1, 2, 3, 4, 5),
        colorHex: '#29B6F6',
        goalDays: 100,
        timeFormat: 'Weeks',
        resetHistory: [DateTime(2024, 1, 1), DateTime(2024, 1, 2)],
        isStopped: true,
        stoppedElapsedSeconds: 12345,
      );

      final second = EventModel(
        id: '2',
        title: 'Second',
        startDateTime: DateTime(2025, 6, 7, 8, 9, 10),
        colorHex: '#B3E5FC',
      );

      final encoded = EventModel.encodeList([first, second]);
      final decoded = EventModel.decodeList(encoded);

      expect(decoded, hasLength(2));
      expect(decoded[0].id, first.id);
      expect(decoded[0].title, first.title);
      expect(decoded[0].startDateTime, first.startDateTime);
      expect(decoded[0].colorHex, first.colorHex);
      expect(decoded[0].goalDays, first.goalDays);
      expect(decoded[0].timeFormat, first.timeFormat);
      expect(decoded[0].resetHistory, first.resetHistory);
      expect(decoded[0].isStopped, first.isStopped);
      expect(decoded[0].stoppedElapsedSeconds, first.stoppedElapsedSeconds);

      expect(decoded[1].id, second.id);
      expect(decoded[1].timeFormat, 'Hours, minutes and seconds');
      expect(decoded[1].resetHistory, isEmpty);
      expect(decoded[1].isStopped, isFalse);
      expect(decoded[1].stoppedElapsedSeconds, isNull);
    });

    test('copyWith updates fields and supports clear flags', () {
      final base = EventModel(
        id: 'base',
        title: 'Base',
        startDateTime: DateTime(2024, 1, 1),
        colorHex: '#FFFFFF',
        goalDays: 10,
        stoppedElapsedSeconds: 50,
      );

      final updated = base.copyWith(
        title: 'Updated',
        goalDays: 20,
        isStopped: true,
      );

      expect(updated.title, 'Updated');
      expect(updated.goalDays, 20);
      expect(updated.isStopped, isTrue);
      expect(updated.stoppedElapsedSeconds, 50);

      final cleared = updated.copyWith(
        clearGoal: true,
        clearStoppedElapsed: true,
      );

      expect(cleared.goalDays, isNull);
      expect(cleared.stoppedElapsedSeconds, isNull);
      expect(cleared.title, 'Updated');
    });
  });
}
