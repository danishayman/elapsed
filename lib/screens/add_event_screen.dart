import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';
import '../theme.dart';
import '../widgets/color_picker_grid.dart';

const _paletteColors = [
  '#7C3AED',
  '#C084FC',
  '#00D4A1',
  '#67E8F9',
  '#A7F3D0',
  '#FDE68A',
  '#FDBA74',
  '#FCA5A5',
  '#DDD6FE',
  '#E2E8F0',
  '#67E8F9',
  '#86EFAC',
  '#FCD34D',
  '#F97316',
];

class AddEventScreen extends StatefulWidget {
  final EventModel? editEvent;

  const AddEventScreen({super.key, this.editEvent});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedColor = _paletteColors[0];

  @override
  void initState() {
    super.initState();
    final edit = widget.editEvent;
    if (edit != null) {
      _titleController.text = edit.title;
      _selectedDate = edit.startDateTime;
      _selectedTime = TimeOfDay.fromDateTime(edit.startDateTime);
      _selectedColor = edit.colorHex;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _startFromNow() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now;
      _selectedTime = TimeOfDay.fromDateTime(now);
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: kAccent),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: kAccent),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an event title')),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time')),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final event = EventModel(
      id: widget.editEvent?.id ?? const Uuid().v4(),
      title: title,
      startDateTime: startDateTime,
      colorHex: _selectedColor,
      goalDays: widget.editEvent?.goalDays,
      resetHistory: widget.editEvent?.resetHistory,
    );

    final events = await StorageService.loadEvents();
    if (widget.editEvent != null) {
      final idx = events.indexWhere((e) => e.id == event.id);
      if (idx != -1) events[idx] = event;
    } else {
      events.add(event);
    }
    await StorageService.saveEvents(events);
    await WidgetService.updateWidgets();

    if (mounted) Navigator.pop(context, true);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editEvent != null ? 'Edit Event' : 'Add New Event'),
        backgroundColor: kBgBlack,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            const Text(
              'Event Title',
              style: TextStyle(color: kTextSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: kTextPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. No smoking',
                hintStyle: const TextStyle(color: kTextTertiary),
                filled: true,
                fillColor: kCardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kCardRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Quick start
            const Text(
              'Quick Start',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _startFromNow,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('START FROM NOW'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kAccent,
                  side: const BorderSide(color: kAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kCardRadius),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Custom date & time
            const Text(
              'Or Select Custom Date & Time',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PickerButton(
                    label: _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : 'SELECT DATE',
                    icon: Icons.calendar_today,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerButton(
                    label: _selectedTime != null
                        ? _formatTime(_selectedTime!)
                        : 'SELECT TIME',
                    icon: Icons.access_time,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Color picker
            const Text(
              'Select Color',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ColorPickerGrid(
              colors: _paletteColors,
              selectedColor: _selectedColor,
              onColorSelected: (c) => setState(() => _selectedColor = c),
            ),

            const SizedBox(height: 36),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _save,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kAccent,
                  side: const BorderSide(color: kAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kCardRadius),
                  ),
                ),
                child: const Text(
                  'SAVE EVENT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: kTextSecondary,
        side: const BorderSide(color: kDivider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      ),
    );
  }
}
