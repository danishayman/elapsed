import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/event_detail_screen.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/widget_service.dart';
import 'theme.dart';

void main() => runApp(const ElapsedApp());

/// Global navigator key so we can navigate from anywhere.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ElapsedApp extends StatelessWidget {
  const ElapsedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elapsed',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      navigatorKey: navigatorKey,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  static const _channel = MethodChannel('com.example.elapsed/deeplink');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetService.updateWidgets();

    // Check if app was launched from a widget tap
    _handleInitialLink();

    // Listen for new intents while app is running (singleTop)
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNewIntent') {
        final uri = call.arguments as String?;
        if (uri != null) _handleDeepLink(uri);
      }
    });
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _channel.invokeMethod<String>('getInitialLink');
      if (uri != null) {
        // Small delay to let the widget tree build before navigating
        await Future.delayed(const Duration(milliseconds: 300));
        _handleDeepLink(uri);
      }
    } catch (_) {}
  }

  void _handleDeepLink(String uriString) async {
    final uri = Uri.tryParse(uriString);
    if (uri == null || uri.scheme != 'elapsed' || uri.host != 'event') return;

    // URI format: elapsed://event/{eventId}
    final eventId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    if (eventId == null) return;

    final events = await StorageService.loadEvents();
    final event = events.where((e) => e.id == eventId).firstOrNull;
    if (event == null) return;

    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetService.updateWidgets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
