import 'package:flutter/material.dart';
import '../theme.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardLightAlt,
                  borderRadius: BorderRadius.circular(kCardRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kAccent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(kCardRadius),
                          ),
                          child: const Icon(
                            Icons.timer_outlined,
                            color: kAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Elapsed',
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Elapsed helps you track how long it has been since '
                      'important personal events. Whether you\'re counting days '
                      'smoke-free, tracking your gym streak, or remembering '
                      'milestones — this app keeps a live, real-time counter for '
                      'each event.',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _InfoTile(
                      icon: Icons.add_circle_outline,
                      text: 'Tap "+" to create a new tracker',
                    ),
                    const _InfoTile(
                      icon: Icons.palette_outlined,
                      text: 'Choose a color to personalise each event',
                    ),
                    const _InfoTile(
                      icon: Icons.touch_app_outlined,
                      text: 'Long-press an event card to delete it',
                    ),
                    const _InfoTile(
                      icon: Icons.save_outlined,
                      text: 'Events are saved locally on your device',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Center(
                child: Text(
                  'v1.0.0',
                  style: TextStyle(color: kTextTertiary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: kAccent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: kTextSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
