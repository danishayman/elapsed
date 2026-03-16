import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'storage_service.dart';

class WidgetService {
  static const _appGroupId = 'group.com.example.Elapsed';
  static const _dataKey = 'events_json';

  static const _androidProviderNames = [
    'WidgetSmallRestartProvider',
    'WidgetSmallStandardProvider',
    'WidgetSmallTransparentBlackProvider',
    'WidgetSmallTransparentWhiteProvider',
    'WidgetMediumRestartProvider',
    'WidgetMediumStandardProvider',
    'WidgetMediumTransparentBlackProvider',
    'WidgetMediumTransparentWhiteProvider',
    'WidgetLargeRestartProvider',
    'WidgetLargeStandardProvider',
    'WidgetLargeTransparentBlackProvider',
    'WidgetLargeTransparentWhiteProvider',
  ];

  /// Serialize current events and push to native home screen widgets.
  static Future<void> updateWidgets() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);

      final events = await StorageService.loadEvents();
      final jsonString = jsonEncode(events.map((e) => e.toJson()).toList());
      await HomeWidget.saveWidgetData<String>(_dataKey, jsonString);

      for (final provider in _androidProviderNames) {
        await HomeWidget.updateWidget(
          androidName: provider,
          iOSName: 'TimeSinceWidget',
        );
      }
    } catch (_) {
      // Silently fail - widgets are best-effort
    }
  }
}
