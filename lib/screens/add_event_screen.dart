import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';
import '../theme.dart';
import '../widgets/color_picker_grid.dart';

const _paletteColors = [
  // Row 1 – lightest
  '#B3E5FC', // light blue
  '#C8E6C9', // light green
  '#FFF9C4', // light yellow
  '#FFE0B2', // light peach
  '#F8BBD0', // light pink
  // Row 2 – medium
  '#29B6F6', // blue
  '#66BB6A', // green
  '#FFEE58', // yellow
  '#FFA726', // orange
  '#EF5350', // red / pink
  // Row 3 – darkest
  '#0277BD', // dark blue
  '#2E7D32', // dark green
  '#F9A825', // dark gold
  '#E65100', // dark orange
  '#B71C1C', // dark red
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

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: kAccent),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    setState(() => _selectedDate = date);

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: kAccent),
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
      timeFormat: widget.editEvent?.timeFormat ?? 'Days',
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
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editEvent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit timer' : 'New timer'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              isEditing ? 'Save' : 'Start',
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // ── Label ──
            const Text(
              'Label',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: kTextPrimary, fontSize: 14),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "For example: No Smoking",
                hintStyle: const TextStyle(color: kTextTertiary, fontSize: 14),
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kCardRadius),
                  borderSide: const BorderSide(color: kDivider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kCardRadius),
                  borderSide: const BorderSide(color: kDivider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kCardRadius),
                  borderSide: const BorderSide(color: kTextPrimary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Choose color ──
            const Text(
              'Choose color',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ColorPickerGrid(
              colors: _paletteColors,
              selectedColor: _selectedColor,
              onColorSelected: (c) => setState(() => _selectedColor = c),
            ),

            const SizedBox(height: 32),

            // ── Event date & time ──
            GestureDetector(
              onTap: _pickDateTime,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 48,
                    color: _selectedDate != null
                        ? kTextPrimary
                        : kTextSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedDate != null && _selectedTime != null
                        ? '${_formatDate(_selectedDate!)}  •  ${_formatTime(_selectedTime!)}'
                        : 'Event date & time',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? kTextPrimary
                          : kTextSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Start from now (preserved functionality) ──
            TextButton(
              onPressed: _startFromNow,
              child: const Text(
                'or start from now',
                style: TextStyle(
                  color: kAccent,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: kTextTertiary,
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
