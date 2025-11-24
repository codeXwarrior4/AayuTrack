import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
    Locale('kn')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AayuTrack'**
  String get appName;

  /// No description provided for @trustedUsers.
  ///
  /// In en, this message translates to:
  /// **'Trusted by thousands of users'**
  String get trustedUsers;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Your health is your real wealth.'**
  String get quote;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get trackProgress;

  /// No description provided for @trackProgressDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor daily tasks and visualize your wellness journey.'**
  String get trackProgressDesc;

  /// No description provided for @aiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI Recommendations'**
  String get aiRecommendations;

  /// No description provided for @aiRecommendationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Personalized suggestions from your AI wellness guide.'**
  String get aiRecommendationsDesc;

  /// No description provided for @gamifiedExperience.
  ///
  /// In en, this message translates to:
  /// **'Gamified Experience'**
  String get gamifiedExperience;

  /// No description provided for @gamifiedExperienceDesc.
  ///
  /// In en, this message translates to:
  /// **'Achieve health goals through fun challenges and rewards.'**
  String get gamifiedExperienceDesc;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get hello;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Stay consistent • Private • Offline'**
  String get tagline;

  /// No description provided for @stepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsLabel;

  /// No description provided for @heartRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRateLabel;

  /// No description provided for @hydrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get hydrationLabel;

  /// No description provided for @medicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medicationTitle;

  /// No description provided for @manageLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageLabel;

  /// No description provided for @noMedicineLogged.
  ///
  /// In en, this message translates to:
  /// **'No medicines logged yet.'**
  String get noMedicineLogged;

  /// No description provided for @atLabel.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get atLabel;

  /// No description provided for @medicationStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Streak'**
  String get medicationStreakTitle;

  /// No description provided for @stepsStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Steps Streak'**
  String get stepsStreakTitle;

  /// No description provided for @hydrationStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration Streak'**
  String get hydrationStreakTitle;

  /// No description provided for @viewLabel.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewLabel;

  /// No description provided for @addStepsButton.
  ///
  /// In en, this message translates to:
  /// **'Add 1000 steps'**
  String get addStepsButton;

  /// No description provided for @addHydrationButton.
  ///
  /// In en, this message translates to:
  /// **'Add 250 ml'**
  String get addHydrationButton;

  /// No description provided for @remindNow.
  ///
  /// In en, this message translates to:
  /// **'Remind Now'**
  String get remindNow;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// No description provided for @healthTips.
  ///
  /// In en, this message translates to:
  /// **'💧 Drink a glass of water every morning.\n🏃‍♂️ Maintain a 30-minute daily walk routine.\n💊 Take medicines on schedule.'**
  String get healthTips;

  /// No description provided for @ai_health_checkup.
  ///
  /// In en, this message translates to:
  /// **'AI Health Checkup'**
  String get ai_health_checkup;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language:'**
  String get select_language;

  /// No description provided for @describe_symptoms.
  ///
  /// In en, this message translates to:
  /// **'Describe your symptoms'**
  String get describe_symptoms;

  /// No description provided for @speak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get speak;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyze;

  /// No description provided for @ai_diagnosis.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnosis:'**
  String get ai_diagnosis;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing... please wait'**
  String get analyzing;

  /// No description provided for @reminder_title.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder_title;

  /// No description provided for @reminder_add.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get reminder_add;

  /// No description provided for @reminder_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get reminder_edit;

  /// No description provided for @reminder_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get reminder_delete;

  /// No description provided for @reminder_upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Reminders'**
  String get reminder_upcoming;

  /// No description provided for @reminder_no_upcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming reminders'**
  String get reminder_no_upcoming;

  /// No description provided for @reminder_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminder_time;

  /// No description provided for @reminder_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reminder_date;

  /// No description provided for @reminder_repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get reminder_repeat;

  /// No description provided for @reminder_repeat_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get reminder_repeat_daily;

  /// No description provided for @reminder_repeat_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get reminder_repeat_weekly;

  /// No description provided for @reminder_repeat_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reminder_repeat_monthly;

  /// No description provided for @reminder_save.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get reminder_save;

  /// No description provided for @reminder_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reminder_cancel;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @kannada.
  ///
  /// In en, this message translates to:
  /// **'Kannada'**
  String get kannada;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get marathi;

  /// No description provided for @breathingExerciseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to relax & start guided breathing'**
  String get breathingExerciseSubtitle;

  /// No description provided for @breathingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get breathingStart;

  /// No description provided for @breathingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get breathingStop;

  /// No description provided for @breathingTapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get breathingTapToStart;

  /// No description provided for @breathingInhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get breathingInhale;

  /// No description provided for @breathingExhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get breathingExhale;

  /// No description provided for @breathingSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec'**
  String breathingSeconds(Object seconds);

  /// No description provided for @breathingCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get breathingCompletedTitle;

  /// No description provided for @breathingCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You completed the breathing session.'**
  String get breathingCompletedSubtitle;

  /// No description provided for @breathingRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get breathingRestart;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
