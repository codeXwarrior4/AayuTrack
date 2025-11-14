// lib/screens/dashboard_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../services/notification_service.dart';
import '../services/pdf_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/streak_badge.dart';
import '../theme.dart';

/// ---------------------------------------------------------------------------
/// 🏥 AayuTrack Dashboard
/// Refined, fast, and hackathon-ready.
/// - Uses Hive for offline storage
/// - Smart reminders (TTS + local notification)
/// - PDF report generator
/// - Adaptive for dark/light theme
/// ---------------------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final Box _box;
  final FlutterTts _tts = FlutterTts();
  bool _loading = true;

  Map<String, dynamic> profile = {};
  List<Map<String, dynamic>> _medLogs = [];
  int _streakDays = 0;

  // sample realtime metrics (replace later with sensors or APIs)
  int _steps = 2500;
  int _heartRate = 78;
  int _hydration = 1300;

  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    _box = Hive.box('aayutrack_box');
    await NotificationService.init();
    await _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 150));

    profile = Map<String, dynamic>.from(_box.get('profile', defaultValue: {}));
    final rawLogs = List<Map<dynamic, dynamic>>.from(
      _box.get('med_logs', defaultValue: []),
    );
    _medLogs = rawLogs.map((e) => Map<String, dynamic>.from(e)).toList();

    // Compute streak days
    final uniqueDates = <String>{};
    for (final m in _medLogs) {
      if (m['taken'] == true) {
        final dateIso = (m['date'] ?? DateTime.now().toIso8601String());
        uniqueDates.add(dateIso.toString().split('T').first);
      }
    }
    _streakDays = uniqueDates.length;

    _animController.forward();
    setState(() => _loading = false);
  }

  // 🔔 Voice + Notification Reminder
  Future<void> _remindNow() async {
    final name = profile['name'] ?? 'User';
    final msg =
        'Hello $name. This is AayuTrack reminder. Please take your medicine and stay hydrated.';
    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.9);
      await _tts.speak(msg);
      await NotificationService.showInstant(
        title: 'AayuTrack Reminder',
        body: msg,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice reminder & notification sent!')),
        );
      }
    } catch (e) {
      debugPrint('Reminder error: $e');
    }
  }

  // 📄 Quick Report
  Future<void> _generateQuickReport() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final name = profile['name'] ?? 'User';
      final date = DateFormat.yMMMd().add_jm().format(DateTime.now());
      await PdfService.generateCheckupReport(
        patientName: name,
        dateTime: date,
        symptom: 'Daily health stats summary',
        diagnosis:
            'Steps: $_steps • Heart Rate: $_heartRate bpm • Water: $_hydration ml\n\nKeep up your good health routine!',
        lang: 'en',
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF report generated successfully!')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create report: $e')));
    }
  }

  // 🔄 Mark medicine taken
  Future<void> _toggleMed(Map<String, dynamic> med, bool value) async {
    med['taken'] = value;
    final logs = List<Map<dynamic, dynamic>>.from(
      _box.get('med_logs', defaultValue: []),
    );
    final idx = logs.indexWhere((e) => e['id'] == med['id']);
    if (idx >= 0) {
      logs[idx] = med;
    } else {
      logs.add(med);
    }
    await _box.put('med_logs', logs);
    await _loadData();
  }

  // ---------------------------- UI WIDGETS ----------------------------

  Widget _buildHeader() {
    final name = profile['name'] ?? 'Welcome';
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.local_hospital, color: kTeal, size: 38),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello,', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stay consistent • Private • Offline',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_note),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          tooltip: 'Edit Profile',
        ),
      ],
    );
  }

  Widget _buildStats() => FadeTransition(
    opacity: CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    child: Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Steps',
            value: '$_steps',
            icon: Icons.directions_walk,
          ),
        ),
        Expanded(
          child: StatCard(
            title: 'Heart Rate',
            value: '$_heartRate bpm',
            icon: Icons.favorite,
          ),
        ),
        Expanded(
          child: StatCard(
            title: 'Hydration',
            value: '$_hydration ml',
            icon: Icons.local_drink,
          ),
        ),
      ],
    ),
  );

  Widget _buildMedications() {
    final meds = _medLogs.reversed.take(4).toList();
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, color: kTeal, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Medication',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/reminders'),
                  icon: const Icon(Icons.schedule),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const Divider(),
            if (meds.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('No medicines logged yet.'),
              )
            else
              ...meds.map((m) {
                final taken = m['taken'] == true;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    taken ? Icons.check_circle : Icons.circle_outlined,
                    color: taken ? kTeal : Colors.grey,
                  ),
                  title: Text(m['name'] ?? 'Medicine'),
                  subtitle: Text('At ${m['time'] ?? '--'}'),
                  trailing: Checkbox(
                    value: taken,
                    onChanged: (v) => _toggleMed(m, v ?? false),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() => Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.notifications_active),
          label: const Text('Remind Now'),
          onPressed: _remindNow,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Export Report'),
          onPressed: _generateQuickReport,
        ),
      ),
    ],
  );

  Widget _buildHealthTips() => Card(
    margin: const EdgeInsets.only(top: 20),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: kTeal, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '💧 Drink a glass of water every morning.\n'
              '🏃‍♂️ Maintain a 30-minute daily walk routine.\n'
              '💊 Take medicines on schedule.',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ---------------------------- BUILD ----------------------------

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildStats(),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildStreakCard(),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
          ),
          const SizedBox(height: 12),
          _buildMedications(),
          const SizedBox(height: 14),
          _buildActions(),
          _buildHealthTips(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildStreakCard() => StreakBadge(days: _streakDays);
}
