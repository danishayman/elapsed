import 'package:flutter/material.dart';

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
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF7C3AED,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.timer_outlined,
                            color: Color(0xFF7C3AED),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Elapsed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Elapsed helps you track how long it has been since '
                      'important personal events. Whether you\'re counting days '
                      'smoke-free, tracking your gym streak, or remembering '
                      'milestones — this app keeps a live, real-time counter for '
                      'each event.',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InfoTile(
                      icon: Icons.add_circle_outline,
                      text: 'Tap "+ ADD EVENT" to create a new tracker',
                    ),
                    _InfoTile(
                      icon: Icons.palette_outlined,
                      text: 'Choose a color to personalise each event',
                    ),
                    _InfoTile(
                      icon: Icons.touch_app_outlined,
                      text: 'Long-press an event card to delete it',
                    ),
                    _InfoTile(
                      icon: Icons.save_outlined,
                      text: 'Events are saved locally on your device',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'v1.0.0',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
          Icon(icon, color: const Color(0xFF7C3AED), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
