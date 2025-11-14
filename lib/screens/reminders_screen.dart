// lib/screens/reminders_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../theme.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with TickerProviderStateMixin {
  final Box remindersBox = Hive.box('aayutrack_reminders');
  late final AnimationController _lottieController;

  // For AI suggestions
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _generateSmartSuggestions();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  /// 🤖 Generate smart suggestions based on time, habits, and existing reminders
  void _generateSmartSuggestions() {
    final now = DateTime.now();
    final hour = now.hour;

    _suggestions = [];

    // Simple offline logic (expandable later)
    if (hour < 10) {
      _suggestions.add({
        'title': 'Morning Walk 🏃‍♂️',
        'body': 'Go for a 20-minute morning walk.',
        'hour': 7,
        'minute': 30,
      });
      _suggestions.add({
        'title': 'Morning Hydration 💧',
        'body': 'Drink a glass of water after waking up.',
        'hour': 8,
        'minute': 0,
      });
    } else if (hour < 16) {
      _suggestions.add({
        'title': 'Afternoon Medicine 💊',
        'body': 'Take your post-lunch medicine on time.',
        'hour': 14,
        'minute': 0,
      });
      _suggestions.add({
        'title': 'Hydration Check 💧',
        'body': 'Drink a glass of water to stay hydrated.',
        'hour': 15,
        'minute': 0,
      });
    } else {
      _suggestions.add({
        'title': 'Evening Walk 🌇',
        'body': 'Take a short walk to relax your body.',
        'hour': 18,
        'minute': 30,
      });
      _suggestions.add({
        'title': 'Night Medicine 🌙',
        'body': 'Take your night medicine before bed.',
        'hour': 21,
        'minute': 0,
      });
    }

    // Avoid duplicates already saved
    final existingTitles = remindersBox.values
        .map((r) => (r as Map)['title'].toString().toLowerCase())
        .toSet();

    _suggestions.removeWhere((s) =>
        existingTitles.contains(s['title'].toString().toLowerCase()));
  }

  Future<void> _addReminderDialog() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    bool isDaily = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Add Reminder',
          style: TextStyle(fontWeight: FontWeight.bold, color: kTeal),
        ),
        content: StatefulBuilder(
          builder: (context, setStateSB) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.notifications),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bodyController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      prefixIcon: Icon(Icons.message_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      'Time: ${selectedTime.format(context)}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    trailing: TextButton(
                      child: const Text('Change'),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setStateSB(() => selectedTime = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Checkbox(
                        value: isDaily,
                        onChanged: (v) => setStateSB(() => isDaily = v ?? false),
                      ),
                      const Text('Repeat daily'),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: () async {
              final title = titleController.text.trim();
              final body = bodyController.text.trim();
              if (title.isEmpty || body.isEmpty) return;

              if (isDaily) {
                await NotificationService.scheduleDaily(
                  title: title,
                  body: body,
                  time: selectedTime,
                );
              } else {
                final now = DateTime.now();
                final dt = DateTime(now.year, now.month, now.day,
                    selectedTime.hour, selectedTime.minute);
                await NotificationService.schedule(
                  title: title,
                  body: body,
                  time: dt.isBefore(now) ? dt.add(const Duration(days: 1)) : dt,
                );
              }

              if (mounted) Navigator.pop(context);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReminder(int id) async {
    final box = Hive.box('aayutrack_reminders');
    await box.delete(id);
    setState(() {});
  }

  Widget _buildSmartSuggestions() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "💡 Smart Suggestions",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final s = _suggestions[index];
              return GestureDetector(
                onTap: () async {
                  await NotificationService.scheduleDaily(
                    title: s['title'],
                    body: s['body'],
                    time: TimeOfDay(hour: s['hour'], minute: s['minute']),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Added: ${s['title']}")),
                  );
                  setState(() {});
                },
                child: Card(
                  color: Colors.teal.shade50,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kTeal,
                                fontSize: 15)),
                        const SizedBox(height: 8),
                        Text(
                          s['body'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "⏰ ${s['hour'].toString().padLeft(2, '0')}:${s['minute'].toString().padLeft(2, '0')}",
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/reminders.json',
            controller: _lottieController,
            onLoaded: (composition) {
              _lottieController
                ..duration = composition.duration
                ..forward();
            },
            height: 180,
          ),
          const SizedBox(height: 12),
          const Text(
            'No reminders yet!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add one or use Smart Suggestions 💡',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map data) {
    final isDaily = data['type'] == 'daily';
    final title = data['title'] ?? 'Reminder';
    final body = data['body'] ?? '';
    String subtitle = '';
    if (isDaily) {
      subtitle =
          'Repeats daily at ${data['hour'].toString().padLeft(2, '0')}:${data['minute'].toString().padLeft(2, '0')}';
    } else {
      subtitle = 'Once at ${DateFormat('MMM d, h:mm a').format(DateTime.parse(data['time']))}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDaily ? kMint : kTeal.withOpacity(0.8),
          child: Icon(isDaily ? Icons.repeat : Icons.access_time,
              color: Colors.white),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () async => await _deleteReminder(data['id']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminders = remindersBox.values.toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminderDialog,
        backgroundColor: kTeal,
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Add Reminder'),
      ),
      body: SafeArea(
        child: reminders.isEmpty
            ? _buildEmptyState()
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _buildSmartSuggestions(),
                  const SizedBox(height: 10),
                  ...reminders.map((r) {
                    final data = Map<String, dynamic>.from(r);
                    return _buildReminderCard(data);
                  }).toList(),
                  const SizedBox(height: 80),
                ],
              ),
      ),
    );
  }
}
