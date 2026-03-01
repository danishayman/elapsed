import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';
import 'add_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late EventModel _event;
  Timer? _timer;
  String _selectedFormat = 'Days';
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────

  Color get _accentColor =>
      Color(int.parse('FF${_event.colorHex.replaceFirst('#', '')}', radix: 16));

  Duration get _elapsed => DateTime.now().difference(_event.startDateTime);

  String _fullElapsed(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    return '$days days, $hours hours, $minutes minutes, $seconds seconds';
  }

  String _formattedElapsed(Duration d) {
    switch (_selectedFormat) {
      case 'Weeks':
        final weeks = d.inDays ~/ 7;
        final remainingDays = d.inDays % 7;
        return '$weeks weeks, $remainingDays days';
      case 'Months':
        final months = d.inDays ~/ 30;
        final remainingDays = d.inDays % 30;
        return '$months months, $remainingDays days';
      case 'Years':
        final years = d.inDays ~/ 365;
        final remainingDays = d.inDays % 365;
        return '$years years, $remainingDays days';
      default:
        return _fullElapsed(d);
    }
  }

  String _formatStartDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final period = d.hour >= 12 ? 'PM' : 'AM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} at $hour:$minute $period';
  }

  int get _longestStreakDays {
    // Build list of start points from all resets + original start
    final starts = <DateTime>[_event.startDateTime, ..._event.resetHistory];
    starts.sort();

    int longest = 0;
    for (int i = 0; i < starts.length; i++) {
      final end = (i + 1 < starts.length) ? starts[i + 1] : DateTime.now();
      final gap = end.difference(starts[i]).inDays;
      if (gap > longest) longest = gap;
    }
    return longest;
  }

  // ── Actions ──────────────────────────────────────────────

  Future<void> _updateEvent(EventModel updated) async {
    final events = await StorageService.loadEvents();
    final idx = events.indexWhere((e) => e.id == updated.id);
    if (idx != -1) events[idx] = updated;
    await StorageService.saveEvents(events);
    await WidgetService.updateWidgets();
    if (mounted)
      setState(() {
        _event = updated;
        _changed = true;
      });
  }

  Future<void> _setGoal() async {
    final controller = TextEditingController(
      text: _event.goalDays?.toString() ?? '',
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Set Goal', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Number of days',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) Navigator.pop(ctx, val);
            },
            child: const Text(
              'SET',
              style: TextStyle(color: Color(0xFF7C3AED)),
            ),
          ),
        ],
      ),
    );
    if (result != null) {
      await _updateEvent(_event.copyWith(goalDays: result));
    }
  }

  Future<void> _resetEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Event', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will reset the timer to zero. Your streak history will be saved.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'RESET',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final now = DateTime.now();
      final updatedHistory = [..._event.resetHistory, _event.startDateTime];
      await _updateEvent(
        _event.copyWith(startDateTime: now, resetHistory: updatedHistory),
      );
    }
  }

  Future<void> _editEvent() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEventScreen(editEvent: _event)),
    );
    if (result == true) {
      // Reload the event from storage
      final events = await StorageService.loadEvents();
      final updated = events.firstWhere(
        (e) => e.id == _event.id,
        orElse: () => _event,
      );
      setState(() {
        _event = updated;
        _changed = true;
      });
    }
  }

  void _shareEvent() {
    final text =
        '${_event.title} — ${_elapsed.inDays} days and counting! #Elapsed';
    Share.share(text);
  }

  // ── UI ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final elapsed = _elapsed;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _changed) {
          // Return true to signal home screen to reload
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            _event.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 22),
              onPressed: _editEvent,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 22),
              onPressed: _shareEvent,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Hero card ──
              _buildHeroCard(elapsed),
              const SizedBox(height: 20),

              // ── Goal ──
              _buildSection(
                label: 'GOAL',
                child: _event.goalDays != null
                    ? _buildGoalProgress()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _setGoal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2A2A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'SET GOAL',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // ── Start date ──
              _buildSection(
                label: 'START DATE',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Started on: ${_formatStartDate(_event.startDateTime)}',
                    style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Longest streak ──
              _buildSection(
                label: '',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: _accentColor,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Longest Streak',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_longestStreakDays days',
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Reset button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _resetEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFEF4444,
                    ).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFFEF4444),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'RESET EVENT',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(Duration elapsed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: _accentColor, width: 3)),
      ),
      child: Column(
        children: [
          Text(
            _event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _formattedElapsed(elapsed),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Time format selector
          _buildLabel('TIME FORMAT'),
          const SizedBox(height: 10),
          _buildFormatChips(),
          const SizedBox(height: 14),

          // Full elapsed text
          Text(
            _fullElapsed(elapsed),
            style: TextStyle(
              color: _accentColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChips() {
    const formats = ['Days', 'Weeks', 'Months', 'Years'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: formats.map((f) {
        final selected = _selectedFormat == f;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(
              f,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[400],
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selected: selected,
            onSelected: (_) => setState(() => _selectedFormat = f),
            selectedColor: const Color(0xFF7C3AED).withValues(alpha: 0.35),
            backgroundColor: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selected ? const Color(0xFF7C3AED) : Colors.grey[700]!,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalProgress() {
    final progress = _elapsed.inDays / (_event.goalDays ?? 1);
    final clamped = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_elapsed.inDays} / ${_event.goalDays} days',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            Text(
              '${(clamped * 100).toInt()}%',
              style: TextStyle(
                color: _accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 8,
            backgroundColor: const Color(0xFF2A2A2A),
            valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _setGoal,
            child: Text(
              'Change goal',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            _buildLabel(label),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }
}
