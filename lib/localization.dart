// lib/localization.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  Future<bool> load() async {
    final code = locale.languageCode;
    final path = 'assets/l10n/app_$code.arb';
    try {
      final jsonStr = await rootBundle.loadString(path);
      final Map<String, dynamic> data = json.decode(jsonStr);
      _strings = <String, String>{};
      data.forEach((k, v) {
        if (!k.startsWith('@')) {
          _strings[k] = (v ?? '').toString();
        }
      });
      return true;
    } catch (e) {
      // fallback to English
      if (code != 'en') {
        final en = AppLocalizations(const Locale('en'));
        final ok = await en.load();
        if (ok) {
          _strings = en._strings;
          return true;
        }
      }
      _strings = {};
      return false;
    }
  }

  /// Get localized value for key; fallback if provided
  String t(String key, [String? fallback]) => _strings[key] ?? fallback ?? key;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'mr', 'kn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
