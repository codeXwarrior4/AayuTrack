import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../services/notification_service.dart';
import '../services/pdf_service.dart';
import '../services/data_storage_service.dart';
import '../services/health_service.dart';
import '../models/vitals_model.dart';
import '../widgets/stat_card.dart';
import '../theme.dart';
import '../localization.dart';
import 'breathing_exercise_screen.dart';
import '../widgets/breathing_animation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final Box _box = Hive.box('aayutrack_box');
  final DataStorageService _storageService = DataStorageService();
  final HealthService _healthService = HealthService();
  final FlutterTts _tts = FlutterTts();

  bool _loading = true;

  Map<String, dynamic> profile = {};
  List<Map<String, dynamic>> _medLogs = [];
  int _streakMedication = 0;
  int _streakSteps = 0;
  int _streakHydration = 0;

  late final AnimationController _animController;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initialize();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _animController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _loadData();

    await _healthService.requestPermissions();
    await _healthService.syncAllVitals();

    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _healthService.syncAllVitals();
    });
  }

  /// Translator helper
  String tr(BuildContext ctx, String key, [Map<String, String>? params]) {
    final loc = AppLocalizations.of(ctx);
    String s = loc?.t(key) ?? key;

    if (params != null) {
      params.forEach((k, v) => s = s.replaceAll('{$k}', v));
    }
    return s;
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 120));

    profile = Map<String, dynamic>.from(_box.get('profile', defaultValue: {}));

    final rawLogs = List<Map<dynamic, dynamic>>.from(
      _box.get('med_logs', defaultValue: []),
    );
    _medLogs = rawLogs.map((e) => Map<String, dynamic>.from(e)).toList();

    _streakMedication = _box.get('streak_med', defaultValue: 0);
    _streakSteps = _box.get('streak_steps', defaultValue: 0);
    _streakHydration = _box.get('streak_hydration', defaultValue: 0);

    _animController.forward();

    setState(() => _loading = false);
  }

  Future<void> _remindNow() async {
    final name = profile['name'] ?? tr(context, 'user');
    final msg = tr(context, 'reminderMessage', {'name': name});

    try {
      final langCode = Localizations.localeOf(context).languageCode;
      final ttsLang = switch (langCode) {
        'hi' => 'hi-IN',
        'mr' => 'mr-IN',
        'kn' => 'kn-IN',
        _ => 'en-IN',
      };

      await _tts.setLanguage(ttsLang);
      await _tts.setSpeechRate(0.9);
      await _tts.speak(msg);

      await NotificationService.showInstant(
        title: tr(context, 'notifReminderTitle'),
        body: msg,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(context, 'voiceReminderSent'))),
        );
      }
    } catch (e) {
      debugPrint('Reminder error: $e');
    }
  }

  Future<void> _generateQuickReport() async {
    final VitalRecord currentVitals = _storageService.getTodayRecord();

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
      final name = profile['name'] ?? tr(context, 'user');
      final date = DateFormat.yMMMd().add_jm().format(DateTime.now());
      final localeCode = Localizations.localeOf(context).languageCode;

      await PdfService.generateCheckupReport(
        patientName: name,
        dateTime: date,
        symptom: tr(context, 'reportSymptom'),
        diagnosis: "${tr(context, 'steps')}: ${currentVitals.steps} • "
            "${tr(context, 'heartRate')}: ${currentVitals.heartRate.toInt()} bpm • "
            "${tr(context, 'hydration')}: ${currentVitals.hydration.toInt()} ml\n"
            "BP: ${currentVitals.bpSystolic}/${currentVitals.bpDiastolic} mmHg • "
            "SpO2: ${currentVitals.spo2.toStringAsFixed(1)}%"
            "\n\n${tr(context, 'stayConsistent')}",
        lang: localeCode,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(context, 'pdfGenerated'))),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr(context, 'reportFailed')}: $e')),
      );
    }
  }

  Future<void> _markSteps(int amount) async {
    final todayKey = 'last_steps_date';
    final last = _box.get(todayKey);
    final todayStr = DateTime.now().toIso8601String().split('T').first;

    if (last != todayStr && amount >= 1000) {
      _streakSteps++;
      await _box.put('streak_steps', _streakSteps);
      await _box.put(todayKey, todayStr);
    }

    await _storageService.updateSteps(amount);
    await _loadData();
  }

  Future<void> _markHydration(int amountMl) async {
    final todayKey = 'last_hydration_date';
    final last = _box.get(todayKey);
    final todayStr = DateTime.now().toIso8601String().split('T').first;

    if (last != todayStr && amountMl >= 200) {
      _streakHydration++;
      await _box.put('streak_hydration', _streakHydration);
      await _box.put(todayKey, todayStr);
    }

    await _storageService.updateHydration(amountMl);
    await _loadData();
  }

  Future<void> _toggleMed(Map<String, dynamic> m, bool value) async {
    m['taken'] = value;
    final logs = List<Map<dynamic, dynamic>>.from(
      _box.get('med_logs', defaultValue: []),
    );

    final idx = logs.indexWhere((e) => e['id'] == m['id']);
    if (idx >= 0) {
      logs[idx] = m;
    } else {
      logs.add(m);
    }

    await _box.put('med_logs', logs);
    await _loadData();
  }

  Widget _buildHeader() {
    final name = profile['name'] ?? tr(context, 'welcome');

    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.local_hospital, color: kTeal, size: 38),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr(context, 'hello'),
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                tr(context, 'tagline'),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_note),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  Widget _buildStats(VitalRecord vitals) {
    const double statsHeight = 120;

    final stats = [
      _StatBox(
        child: StatCard(
          title: tr(context, 'steps'),
          value: '${vitals.steps}',
          icon: Icons.directions_walk,
        ),
      ),
      _StatBox(
        child: StatCard(
          title: tr(context, 'heartRate'),
          value: '${vitals.heartRate.toInt()} bpm',
          icon: Icons.favorite,
        ),
      ),
      _StatBox(
        child: StatCard(
          title: tr(context, 'hydration'),
          value: '${vitals.hydration.toInt()} ml',
          icon: Icons.local_drink,
        ),
      ),
      _StatBox(
        child: StatCard(
          title: tr(context, 'bpSystolic'),
          value: '${vitals.bpSystolic} mmHg',
          icon: Icons.monitor_heart,
        ),
      ),
      _StatBox(
        child: StatCard(
          title: tr(context, 'spo2'),
          value: '${vitals.spo2.toStringAsFixed(1)}%',
          icon: Icons.bubble_chart,
        ),
      ),
    ];

    return FadeTransition(
      opacity:
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
      child: LayoutBuilder(builder: (ctx, constraints) {
        if (constraints.maxWidth < 450) {
          return SizedBox(
            height: statsHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stats.length,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                return SizedBox(
                  width: (constraints.maxWidth * 0.45).clamp(110.0, 180.0),
                  child: stats[i],
                );
              },
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (_, i) => stats[i],
        );
      }),
    );
  }

  Widget _buildMedications() {
    final meds = _medLogs.reversed.take(4).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, color: kTeal),
                const SizedBox(width: 8),
                Text(
                  tr(context, 'medication'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/reminders'),
                  icon: const Icon(Icons.schedule),
                  label: Text(tr(context, 'manage')),
                ),
              ],
            ),
            const Divider(),
            if (meds.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(tr(context, 'noMedicines')),
              )
            else
              ...meds.map(
                (m) => ListTile(
                  dense: true,
                  title: Text(m['name'] ?? tr(context, 'medicine')),
                  subtitle: Text("${tr(context, 'at')} ${m['time'] ?? '--'}"),
                  trailing: Checkbox(
                    value: m['taken'] == true,
                    onChanged: (v) => _toggleMed(m, v ?? false),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.notifications_active),
            label: Text(tr(context, 'remindNow')),
            onPressed: _remindNow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(tr(context, 'exportReport')),
            onPressed: _generateQuickReport,
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.self_improvement, color: kTeal, size: 32),
        title: Text(
          AppLocalizations.of(context)!.breathingExercise,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(AppLocalizations.of(context)!.breathingTapToStart),
        onTap: () => Navigator.pushNamed(context, '/breathing'),
      ),
    );
  }

  Widget _buildHealthTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          tr(context, 'healthTips'),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ValueListenableBuilder<Box<VitalRecord>>(
      valueListenable: _storageService.vitalRecordsListenable,
      builder: (context, box, child) {
        final currentVitals = _storageService.getTodayRecord();

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildStats(currentVitals),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${tr(context, 'medStreak')}\n$_streakMedication ${tr(context, 'days')}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/reminders'),
                        child: Text(tr(context, 'view')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${tr(context, 'stepsStreak')}\n$_streakSteps ${tr(context, 'days')}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _markSteps(1000),
                        child: Text(tr(context, 'addSteps')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${tr(context, 'hydrationStreak')}\n$_streakHydration ${tr(context, 'days')}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _markHydration(250),
                        child: Text(tr(context, 'addWater')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildMedications(),
              const SizedBox(height: 14),
              _buildActions(),
              const SizedBox(height: 14),
              _buildBreathingCard(),
              const SizedBox(height: 14),
              _buildHealthTips(),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final Widget child;
  const _StatBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: child,
    );
  }
}
