import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme.dart';

Color _parseHex(String hex) {
  final buffer = hex.replaceFirst('#', '');
  return Color(int.parse('FF$buffer', radix: 16));
}

class EventCard extends StatefulWidget {
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
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final days = widget.elapsed.inDays;
    final hours = widget.elapsed.inHours % 24;
    final minutes = widget.elapsed.inMinutes % 60;
    final seconds = widget.elapsed.inSeconds % 60;
    final eventColor = _parseHex(widget.event.colorHex);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: kCardDark,
              borderRadius: BorderRadius.circular(kCardRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kCardRadius),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Left color bar
                    Container(width: 4, color: eventColor),

                    // Card content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title.toUpperCase(),
                              style: const TextStyle(
                                color: kTextSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$days',
                              style: TextStyle(
                                color: eventColor,
                                fontSize: 64,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'days',
                              style: TextStyle(
                                color: kTextTertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${hours}h  ${minutes}m  ${seconds}s',
                              style: const TextStyle(
                                color: Color(0xCCFFFFFF), // ~80% white
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
