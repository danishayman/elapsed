import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class StorageService {
  static const _key = 'elapsed_events';

  static Future<List<EventModel>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];
    return EventModel.decodeList(jsonString);
  }

  static Future<void> saveEvents(List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, EventModel.encodeList(events));
  }
}
