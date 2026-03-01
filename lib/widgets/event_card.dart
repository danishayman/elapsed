import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final Duration elapsed;
  final VoidCallback onLongPress;

  const EventCard({
    super.key,
    required this.event,
    required this.elapsed,
    required this.onLongPress,
  });

  String _format(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    return '${days}d  ${hours}h  ${minutes}m  ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(
      int.parse('FF${event.colorHex.replaceFirst('#', '')}', radix: 16),
    );

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: accentColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _format(elapsed),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
