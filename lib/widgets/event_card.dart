import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final Duration elapsed;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const EventCard({
    super.key,
    required this.event,
    required this.elapsed,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final days = elapsed.inDays;
    final hours = elapsed.inHours % 24;
    final minutes = elapsed.inMinutes % 60;
    final seconds = elapsed.inSeconds % 60;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: kCardDark,
          borderRadius: BorderRadius.circular(kCardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                color: kTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$days',
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 48,
                fontWeight: FontWeight.w700,
                height: 1.0,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'days',
              style: const TextStyle(
                color: kTextTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${hours}h  ${minutes}m  ${seconds}s',
              style: const TextStyle(
                color: kTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
