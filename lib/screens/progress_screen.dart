import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart'; // Assuming kTeal is defined here

// If kTeal isn't in theme.dart, uncomment this:
// const kTeal = Color(0xFF00A389);

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final Box _box = Hive.box('aayutrack_box');

  // Dummy data for the chart (since we might not have 7 days of history yet)
  final List<double> _weeklySteps = [0.3, 0.5, 0.4, 0.7, 0.8, 0.6, 0.9];
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    // Get current stats for the "Summary" section
    final int currentSteps = _box.get('streak_steps', defaultValue: 0);
    final int currentHydration = _box.get('streak_hydration', defaultValue: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Progress"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Weekly Analysis Header
            const Text(
              "Weekly Analysis",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "You are doing better than 65% of users!",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // 2. Custom Bar Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Activity Level",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Icon(Icons.bar_chart, color: kTeal),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      return _buildBar(
                        _days[index],
                        _weeklySteps[index],
                        index == 6, // Highlight the last bar (Today)
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. Summary Stats Grid
            const Text(
              "Consistency Stats",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.local_fire_department,
                    value: "$currentSteps Days",
                    label: "Step Streak",
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.water_drop,
                    value: "$currentHydration Days",
                    label: "Hydration",
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 4. Achievements / Badges
            const Text(
              "Achievements",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildAchievementTile(
              title: "Early Bird",
              subtitle: "Completed 5 morning walks",
              icon: Icons.wb_sunny,
              color: Colors.amber,
              isUnlocked: true,
            ),
            const SizedBox(height: 10),
            _buildAchievementTile(
              title: "Hydration Hero",
              subtitle: "Drank 2000ml for 7 days",
              icon: Icons.emoji_events,
              color: Colors.purple,
              isUnlocked: false,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper to build a single bar in the chart
  Widget _buildBar(String label, double pct, bool isActive) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 120 * pct, // Dynamic height
          decoration: BoxDecoration(
            color: isActive ? kTeal : Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? kTeal : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isUnlocked,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: isUnlocked ? null : Border.all(color: Colors.grey[300]!),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? color.withOpacity(0.1) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle, color: kTeal, size: 20)
          else
            const Icon(Icons.lock, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
