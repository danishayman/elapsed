import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'storage_service.dart';

class WidgetService {
  static const _appGroupId = 'group.com.example.Elapsed';
  static const _dataKey = 'events_json';

  /// Serialize current events and push to native home screen widgets.
  static Future<void> updateWidgets() async {
    try {
      // Set the App Group for iOS
      await HomeWidget.setAppGroupId(_appGroupId);

      final events = await StorageService.loadEvents();
      final jsonString = jsonEncode(events.map((e) => e.toJson()).toList());

      await HomeWidget.saveWidgetData<String>(_dataKey, jsonString);

      // Update all Android widget providers
      await HomeWidget.updateWidget(
        androidName: 'TimeSinceSmallWidgetProvider',
        iOSName: 'TimeSinceWidget',
      );
      await HomeWidget.updateWidget(
        androidName: 'TimeSinceMediumWidgetProvider',
        iOSName: 'TimeSinceWidget',
      );
      await HomeWidget.updateWidget(
        androidName: 'TimeSinceLargeWidgetProvider',
        iOSName: 'TimeSinceWidget',
      );
    } catch (_) {
      // Silently fail — widgets are best-effort
    }
  }
}
