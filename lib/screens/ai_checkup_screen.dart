// lib/screens/ai_checkup_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../services/pdf_service.dart';
import '../theme.dart';

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

  @override
  void dispose() {
    _symptomController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _analyzeSymptoms() async {
    final input = _symptomController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter symptoms first.")));
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _showResult = false;
      _aiResult = null;
    });

    await Future.delayed(const Duration(seconds: 2));
    final result = _generateMockDiagnosis(input);

    setState(() {
      _aiResult = result;
      _isAnalyzing = false;
      _showResult = true;
    });

    _speak(result);
    _saveCheckup(input, result);
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage(
      _selectedLang == 'en'
          ? 'en-IN'
          : _selectedLang == 'hi'
          ? 'hi-IN'
          : 'mr-IN',
    );
    await _tts.speak(text);
  }

  void _saveCheckup(String symptom, String result) {
    final history = List<Map>.from(
      box.get('checkup_history', defaultValue: []),
    );
    history.add({
      'symptom': symptom,
      'result': result,
      'time': DateTime.now().toIso8601String(),
      'lang': _selectedLang,
    });

    if (history.length > 10) history.removeAt(0);
    box.put('checkup_history', history);
  }

  String _generateMockDiagnosis(String symptom) {
    final random = Random();
    final conditions = [
      {
        'name': 'Mild Cold',
        'severity': 1,
        'advice': 'Drink warm fluids and take rest.',
      },
      {
        'name': 'Dehydration',
        'severity': 2,
        'advice': 'Increase water intake.',
      },
      {
        'name': 'Stress / Fatigue',
        'severity': 0,
        'advice': 'Sleep well & reduce screen time.',
      },
      {
        'name': 'Headache',
        'severity': 1,
        'advice': 'take rest and compress on your forehead',
      }
    ];

    final pick = conditions[random.nextInt(conditions.length)];
    final severity = pick['severity'] as int;
    final emoji = ['🙂', '😐', '😷'][severity];

    return "🩺 Condition: ${pick['name']} $emoji\n\n"
        "Severity: ${['Low', 'Medium', 'High'][severity]}\n\n"
        "Advice: ${pick['advice']}";
  }

  Future<void> _downloadPdf() async {
    if (_aiResult == null) return;

    await PdfService.generateCheckupReport(
      patientName: "User",
      dateTime: DateFormat.yMMMd().add_jm().format(DateTime.now()),
      symptom: _symptomController.text.trim(),
      diagnosis: _aiResult!,
      lang: _selectedLang,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("PDF saved in Downloads.")));
  }

  Widget _langButton(String label, String code) {
    final active = _selectedLang == code;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedLang = code),
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? kTeal : Colors.grey.shade300,
          foregroundColor: active ? Colors.white : Colors.black,
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Health Checkup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Icon(
              Icons.smart_toy,
              size: 140,
              color: kTeal,
            ), // replacing doctor animation
            const SizedBox(height: 16),

            TextField(
              controller: _symptomController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Describe your symptoms...",
                prefixIcon: const Icon(Icons.healing),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _langButton("English", "en"),
                const SizedBox(width: 6),
                _langButton("हिंदी", "hi"),
                const SizedBox(width: 6),
                _langButton("मराठी", "mr"),
              ],
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.medical_services),
              label: const Text("Analyze Symptoms"),
              onPressed: _isAnalyzing ? null : _analyzeSymptoms,
            ),

            const SizedBox(height: 20),

            if (_isAnalyzing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: kTeal),
                ),
              ),

            if (_showResult && _aiResult != null)
              Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _aiResult!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Download Report"),
                    onPressed: _downloadPdf,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
