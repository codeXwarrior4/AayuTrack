import 'package:flutter/material.dart';

// Assuming kTeal is defined globally or in a separate theme file
const kTeal = Color(0xFF00A389);

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color; // <<< THE REQUIRED FIX

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color, // <<< NOW ACCEPTED BY CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color:
          color ?? Theme.of(context).cardColor, // Use custom color if provided
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: kTeal, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
