import 'package:flutter/material.dart';
import '../main.dart';
import '../localization.dart';

class LanguageScreen extends StatelessWidget {
  final Function(Locale) onChangedLocale;

  const LanguageScreen({super.key, required this.onChangedLocale});

  @override
  Widget build(BuildContext context) {
    final theme = MyAppTheme.of(context);
    final loc = AppLocalizations.of(context);

    final languages = {
      'en': loc?.english ?? 'English',
      'hi': loc?.hindi ?? 'Hindi',
      'mr': loc?.marathi ?? 'Marathi',
      'kn': loc?.kannada ?? 'Kannada',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.select_language ?? 'Select Language'),
      ),
      body: ListView(
        children: languages.entries.map((entry) {
          return ListTile(
            title: Text(entry.value),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              final locale = Locale(entry.key);
              theme?.changeLocale(locale);
              onChangedLocale(locale);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
