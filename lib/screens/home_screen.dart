import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';
import '../theme.dart';
import '../widgets/event_card.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<EventModel> _events = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final events = await StorageService.loadEvents();
    if (mounted) setState(() => _events = events);
  }

  Future<void> _deleteEvent(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete Event',
          style: TextStyle(color: kTextPrimary),
        ),
        content: Text(
          'Remove "${_events[index].title}"?',
          style: const TextStyle(color: kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: kTextTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _events.removeAt(index));
      await StorageService.saveEvents(_events);
      await WidgetService.updateWidgets();
    }
  }

  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEventScreen()),
    );
    if (result == true) _loadEvents();
  }

  Future<void> _navigateToDetail(EventModel event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
    _loadEvents();
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _events.removeAt(oldIndex);
      _events.insert(newIndex, item);
    });
    await StorageService.saveEvents(_events);
    await WidgetService.updateWidgets();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: kBgWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and settings button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Elapsed',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: kTextPrimary, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Events list
            Expanded(
              child: _events.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No events yet',
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tap + to get started',
                            style: TextStyle(
                              color: kTextTertiary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: _events.length,
                      onReorder: _onReorder,
                      proxyDecorator: (child, index, animation) {
                        return Opacity(
                          opacity: 0.4,
                          child: Material(
                            elevation: 4,
                            color: kBgWhite,
                            shadowColor: Colors.black26,
                            child: child,
                          ),
                        );
                      },
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        final elapsed = now.difference(event.startDateTime);
                        return EventCard(
                          key: ValueKey(event.id),
                          event: event,
                          elapsed: elapsed,
                          index: index,
                          onTap: () => _navigateToDetail(event),
                          onLongPress: () => _deleteEvent(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // Black circular FAB with white +
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
