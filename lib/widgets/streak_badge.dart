// lib/widgets/streak_badge.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StreakBadge extends StatelessWidget {
  final int days;

  const StreakBadge({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = days <= 0
        ? 'No streak'
        : '$days day${days == 1 ? '' : 's'}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Lottie.asset(
                'assets/animations/success.json',
                repeat: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak',
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    display,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Keep your daily habits to grow your streak!',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // encourage action: open reminders
                Navigator.of(context).pushNamed('/reminders');
              },
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}
