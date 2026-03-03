import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/widget_service.dart';
import 'theme.dart';

void main() => runApp(const ElapsedApp());

class ElapsedApp extends StatelessWidget {
  const ElapsedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elapsed',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetService.updateWidgets();
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
