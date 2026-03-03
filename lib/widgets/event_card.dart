import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme.dart';

Color _parseHex(String hex) {
  final buffer = hex.replaceFirst('#', '');
  return Color(int.parse('FF$buffer', radix: 16));
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final Duration elapsed;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const EventCard({
    super.key,
    required this.event,
    required this.elapsed,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  String _formatElapsed() {
    final days = elapsed.inDays;
    final hours = elapsed.inHours % 24;
    final minutes = elapsed.inMinutes % 60;
    final seconds = elapsed.inSeconds % 60;

    final hh = hours.toString().padLeft(2, '0');
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');

    if (days > 0) {
      return '${days}d $hh:$mm:$ss';
    }
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final eventColor = _parseHex(event.colorHex);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                // Drag handle — hold to reorder
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(
                    Icons.drag_handle,
                    color: kTextTertiary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Colored time badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: eventColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatElapsed(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Event title
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Thin divider
          const Divider(height: 1, thickness: 0.5, color: kDivider),
        ],
      ),
    );
  }
}
