import 'package:flutter/material.dart';
import '../widgets/breathing_animation.dart';
import '../localization.dart';

class BreathingExerciseScreen extends StatelessWidget {
  const BreathingExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.breathingExercise),
      ), // Localized title
      body: const Center(
        child: BreathingAnimation(durationSeconds: 60),
      ),
    );
  }
}
