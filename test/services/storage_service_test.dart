import 'package:elapsed/models/event_model.dart';
import 'package:elapsed/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('seeds default event once on first launch', () async {
    final firstLoad = await StorageService.loadEvents();

    expect(firstLoad.length, 1);
    expect(firstLoad.first.title, 'Using Elapsed App :)');
    expect(firstLoad.first.timeFormat, 'Days');

    final secondLoad = await StorageService.loadEvents();
    expect(secondLoad.length, 1);
    expect(secondLoad.first.id, firstLoad.first.id);
  });

  test('does not add default event when events already exist', () async {
    final existingEvent = EventModel(
      id: 'existing',
      title: 'Existing Event',
      startDateTime: DateTime(2026, 1, 1),
      colorHex: '#B3E5FC',
    );

    SharedPreferences.setMockInitialValues({
      'elapsed_events': EventModel.encodeList([existingEvent]),
    });

    final initialLoad = await StorageService.loadEvents();
    expect(initialLoad.length, 1);
    expect(initialLoad.first.id, 'existing');

    await StorageService.saveEvents([]);
    final afterDeleteLoad = await StorageService.loadEvents();
    expect(afterDeleteLoad, isEmpty);
  });
}
