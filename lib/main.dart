import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/info_screen.dart';
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
  int _currentIndex = 0;

  final _pages = const [HomeScreen(), InfoScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Push initial data to widgets on launch
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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: kBgBlack,
        selectedItemColor: kAccent,
        unselectedItemColor: kTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}
