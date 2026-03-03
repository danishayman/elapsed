import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';
import '../theme.dart';
import 'add_event_screen.dart';
import 'format_screen.dart';

Color _parseHex(String hex) {
  final buffer = hex.replaceFirst('#', '');
  return Color(int.parse('FF$buffer', radix: 16));
}

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late EventModel _event;
  Timer? _timer;
  late String _selectedFormat;
  bool _changed = false;
  bool _isPaused = false;
  Duration? _pausedElapsed;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _selectedFormat = _event.timeFormat;
    // Restore persisted stopped state
    if (_event.isStopped && _event.stoppedElapsedSeconds != null) {
      _isPaused = true;
      _pausedElapsed = Duration(seconds: _event.stoppedElapsedSeconds!);
    }
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

  Duration get _elapsed {
    if (_isPaused && _pausedElapsed != null) return _pausedElapsed!;
    return DateTime.now().difference(_event.startDateTime);
  }

  String _compactElapsed(Duration d) {
    switch (_selectedFormat) {
      case 'Years':
        final years = d.inDays ~/ 365;
        final remainingDays = d.inDays % 365;
        return '${years}y ${remainingDays}d';
      case 'Months':
        final months = d.inDays ~/ 30;
        final remainingDays = d.inDays % 30;
        return '${months}m ${remainingDays}d';
      case 'Weeks':
        final weeks = d.inDays ~/ 7;
        final remainingDays = d.inDays % 7;
        return '${weeks}w ${remainingDays}d';
      case 'Hours, minutes and seconds':
        final hours = d.inHours;
        final minutes = d.inMinutes % 60;
        final seconds = d.inSeconds % 60;
        final hh = hours.toString().padLeft(2, '0');
        final mm = minutes.toString().padLeft(2, '0');
        final ss = seconds.toString().padLeft(2, '0');
        return '$hh:$mm:$ss';
      default: // Days
        final days = d.inDays;
        final hours = d.inHours % 24;
        final minutes = d.inMinutes % 60;
        final seconds = d.inSeconds % 60;
        final hh = hours.toString().padLeft(2, '0');
        final mm = minutes.toString().padLeft(2, '0');
        final ss = seconds.toString().padLeft(2, '0');
        if (days > 0) return '${days}d $hh:$mm:$ss';
        return '$hh:$mm:$ss';
    }
  }

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
      case 'Hours, minutes and seconds':
        final hours = d.inHours;
        final minutes = d.inMinutes % 60;
        final seconds = d.inSeconds % 60;
        return '$hours hours, $minutes minutes, $seconds seconds';
      default:
        return _fullElapsed(d);
    }
  }

  String _formatStartDateShort(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} $hour:$minute';
  }

  int get _longestStreakDays {
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
    if (mounted) {
      setState(() {
        _event = updated;
        _changed = true;
      });
    }
  }

  Future<void> _restartEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Restart Timer',
          style: TextStyle(color: kTextPrimary),
        ),
        content: const Text(
          'This will restart the timer from now. Your history will be saved.',
          style: TextStyle(color: kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: kTextTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('RESTART', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final now = DateTime.now();
      final updatedHistory = [..._event.resetHistory, _event.startDateTime];
      _isPaused = false;
      _pausedElapsed = null;
      await _updateEvent(
        _event.copyWith(
          startDateTime: now,
          resetHistory: updatedHistory,
          isStopped: false,
          clearStoppedElapsed: true,
        ),
      );
    }
  }

  Future<void> _togglePause() async {
    if (_isPaused) {
      // Resume: adjust start time so elapsed continues from paused value
      final pausedDur = _pausedElapsed!;
      final updated = _event.copyWith(
        startDateTime: DateTime.now().subtract(pausedDur),
        isStopped: false,
        clearStoppedElapsed: true,
      );
      setState(() {
        _isPaused = false;
        _pausedElapsed = null;
      });
      await _updateEvent(updated);
    }
  }

  Future<void> _stopEvent() async {
    if (!_isPaused) {
      final elapsed = DateTime.now().difference(_event.startDateTime);
      setState(() {
        _pausedElapsed = elapsed;
        _isPaused = true;
      });
      await _updateEvent(
        _event.copyWith(
          isStopped: true,
          stoppedElapsedSeconds: elapsed.inSeconds,
        ),
      );
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete Timer',
          style: TextStyle(color: kTextPrimary),
        ),
        content: Text(
          'Remove "${_event.title}"? This cannot be undone.',
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
      final events = await StorageService.loadEvents();
      events.removeWhere((e) => e.id == _event.id);
      await StorageService.saveEvents(events);
      await WidgetService.updateWidgets();
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _editEvent() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEventScreen(editEvent: _event)),
    );
    if (result == true) {
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
    SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _showFormatPicker() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => FormatScreen(selectedFormat: _selectedFormat),
      ),
    );
    if (result != null && mounted) {
      setState(() => _selectedFormat = result);
      await _updateEvent(_event.copyWith(timeFormat: result));
    }
  }

  void _showRestartHistory() {
    final allStarts = <DateTime>[..._event.resetHistory, _event.startDateTime];
    allStarts.sort((a, b) => b.compareTo(a));

    showModalBottomSheet(
      context: context,
      backgroundColor: kBgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Restart History',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Longest streak: $_longestStreakDays days',
                    style: const TextStyle(
                      color: kAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_event.resetHistory.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No restarts yet',
                        style: TextStyle(color: kTextTertiary, fontSize: 14),
                      ),
                    ),
                  )
                else
                  ...allStarts.map(
                    (d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: kTextTertiary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatStartDateShort(d),
                            style: const TextStyle(
                              color: kTextSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final elapsed = _elapsed;
    final eventColor = _parseHex(_event.colorHex);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _changed) {
          // Return true to signal home screen to reload
        }
      },
      child: Scaffold(
        backgroundColor: kBgWhite,
        appBar: AppBar(
          backgroundColor: kBgWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Timer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: kTextPrimary),
              onPressed: _shareEvent,
            ),
          ],
        ),
        body: Column(
          children: [
            const Divider(height: 1, color: kDivider),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),

                    // ── Hero: colored badge + title ──
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: eventColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _compactElapsed(elapsed),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _event.title,
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Actions ──
                    _buildSectionHeader('Actions'),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildIconAction(
                            icon: Icons.restart_alt_rounded,
                            label: 'Restart',
                            onTap: _restartEvent,
                          ),
                          _buildIconAction(
                            icon: Icons.play_arrow_outlined,
                            label: 'Resume',
                            onTap: _togglePause,
                            enabled: _isPaused,
                          ),
                          _buildIconAction(
                            icon: Icons.stop_outlined,
                            label: 'Stop',
                            onTap: _stopEvent,
                            enabled: !_isPaused,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Options ──
                    _buildSectionHeader('Options'),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildIconAction(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            onTap: _editEvent,
                          ),
                          _buildIconAction(
                            icon: Icons.timer_outlined,
                            label: 'Format',
                            onTap: _showFormatPicker,
                          ),
                          _buildIconAction(
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            onTap: _deleteEvent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Complements ──
                    _buildSectionHeader('Complements'),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildIconAction(
                            icon: Icons.bar_chart_rounded,
                            label: 'Restarts',
                            onTap: _showRestartHistory,
                          ),
                          _buildIconAction(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: _showNotificationsDialog,
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Bottom: Started on ──
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Center(
                child: Text(
                  'Started on ${_formatStartDateShort(_event.startDateTime)}',
                  style: const TextStyle(color: kTextTertiary, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: kTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildIconAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final color = enabled ? kTextPrimary : kTextTertiary;
    final labelColor = enabled ? kTextSecondary : kTextTertiary;
    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
