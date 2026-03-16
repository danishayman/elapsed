import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';

class StorageService {
  static const _key = 'elapsed_events';
  static const _defaultEventSeededKey = 'elapsed_default_event_seeded';

  static Future<List<EventModel>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    var events = <EventModel>[];
    if (jsonString != null && jsonString.isNotEmpty) {
      events = EventModel.decodeList(jsonString);
    }

    final hasSeededDefaultEvent =
        prefs.getBool(_defaultEventSeededKey) ?? false;
    if (!hasSeededDefaultEvent) {
      if (events.isEmpty) {
        final now = DateTime.now();
        events = [
          EventModel(
            id: const Uuid().v4(),
            title: 'Using Elapsed App :)',
            startDateTime: now,
            colorHex: '#29B6F6',
            timeFormat: 'Days',
          ),
        ];
        await prefs.setString(_key, EventModel.encodeList(events));
      }
      await prefs.setBool(_defaultEventSeededKey, true);
    }

    return events;
  }

  static Future<void> saveEvents(List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, EventModel.encodeList(events));
  }

  static const _timeFormatKey = 'elapsed_time_format';

  static Future<String> loadTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_timeFormatKey) ?? 'Hours, minutes and seconds';
  }

  static Future<void> saveTimeFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeFormatKey, format);
  }
}
