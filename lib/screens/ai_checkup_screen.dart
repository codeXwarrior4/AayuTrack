import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../services/pdf_service.dart';
import '../theme.dart';

/// ---------------------------------------------------------------------------
/// 🤖 AI Health Checkup Screen
/// - Smart language toggle (English, Hindi, Marathi)
/// - Animated AI assistant
/// - PDF report generation
/// - Local history persistence
/// ---------------------------------------------------------------------------
class AiCheckupScreen extends StatefulWidget {
  const AiCheckupScreen({super.key});

  @override
  State<AiCheckupScreen> createState() => _AiCheckupScreenState();
}

class _AiCheckupScreenState extends State<AiCheckupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _symptomController = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  final Box box = Hive.box('aayutrack_box');

  String _selectedLang = 'en';
  String? _aiResult;
  bool _isAnalyzing = false;
  bool _showResult = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _animController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _analyzeSymptoms() async {
    final symptom = _symptomController.text.trim();
    if (symptom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your symptoms.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _showResult = false;
      _aiResult = null;
    });

    _animController.repeat();

    await Future.delayed(const Duration(seconds: 2));
    final result = _generateMockDiagnosis(symptom);

    setState(() {
      _aiResult = result;
      _isAnalyzing = false;
      _showResult = true;
    });

    _animController.stop();

    await _speak(result);
    _saveCheckup(symptom, result);
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage(
      _selectedLang == 'en'
          ? 'en-IN'
          : _selectedLang == 'hi'
          ? 'hi-IN'
          : 'mr-IN',
    );
    await _tts.setSpeechRate(0.9);
    await _tts.speak(text);
  }

  void _saveCheckup(String symptom, String result) {
    final history = List<Map>.from(
      box.get('checkup_history', defaultValue: []),
    );
    history.add({
      'symptom': symptom,
      'result': result,
      'lang': _selectedLang,
      'time': DateTime.now().toIso8601String(),
    });
    while (history.length > 10) {
      history.removeAt(0);
    }
    box.put('checkup_history', history);
  }

  String _generateMockDiagnosis(String symptom) {
    final random = Random();
    final conditions = [
      {
        'name': 'Mild Cold',
        'severity': 1,
        'advice':
            'Drink warm fluids and rest. Consult a doctor if fever persists.',
      },
      {
        'name': 'Dehydration',
        'severity': 2,
        'advice':
            'Increase water intake and eat fruits. Avoid caffeine and alcohol.',
      },
      {
        'name': 'Fatigue or Stress',
        'severity': 0,
        'advice': 'Take short breaks, get 8 hours of sleep, and stay hydrated.',
      },
      {
        'name': 'Digestive Upset',
        'severity': 2,
        'advice': 'Eat light meals, avoid spicy foods, and stay hydrated.',
      },
      {
        'name': 'Allergy',
        'severity': 1,
        'advice': 'Avoid allergens and consult a doctor if symptoms persist.',
      },
    ];

    final pick = conditions[random.nextInt(conditions.length)];
    final name = pick['name'];
    final advice = pick['advice'];
    final severity = pick['severity'] as int;
    final emoji = ['🙂', '😐', '😷'][severity.clamp(0, 2)];
    final levels = ['Low', 'Moderate', 'High'];

    return '🩺 Condition: $name $emoji\n\nSeverity: ${levels[severity]}\n\nAdvice: $advice';
  }

  Future<void> _downloadPdf() async {
    if (_aiResult == null) return;
    final now = DateFormat.yMMMd().add_jm().format(DateTime.now());
    await PdfService.generateCheckupReport(
      patientName: 'User',
      dateTime: now,
      symptom: _symptomController.text.trim(),
      diagnosis: _aiResult!,
      lang: _selectedLang,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF report saved in Downloads folder')),
    );
  }

  Widget _langButton(String label, String code) {
    final active = _selectedLang == code;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedLang = code),
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? kTeal : Colors.grey[300],
          foregroundColor: active ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Health Checkup'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Lottie.asset(
                'assets/animations/ai_doctor.json',
                width: 180,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _symptomController,
              decoration: InputDecoration(
                hintText: 'Enter your symptoms...',
                prefixIcon: const Icon(Icons.healing),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _langButton('English', 'en'),
                const SizedBox(width: 6),
                _langButton('हिंदी', 'hi'),
                const SizedBox(width: 6),
                _langButton('मराठी', 'mr'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.medical_information),
              label: const Text('Analyze Symptoms'),
              onPressed: _isAnalyzing ? null : _analyzeSymptoms,
            ),
            const SizedBox(height: 20),
            if (_isAnalyzing)
              Center(
                child: Lottie.asset(
                  'assets/animations/ai_loading.json',
                  width: 150,
                ),
              ),
            if (_showResult && _aiResult != null) ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Card(
                  key: ValueKey(_aiResult),
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _aiResult!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Download Report'),
                onPressed: _downloadPdf,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
