// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final box = Hive.box('aayutrack_box');
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _darkMode = box.get('darkMode', defaultValue: false);
    _notificationsEnabled = box.get('notifications', defaultValue: true);
  }

  void _toggleDarkMode(bool value) async {
    setState(() => _darkMode = value);
    await box.put('darkMode', value);
    MyAppTheme.of(context)?.toggleTheme(value);
  }

  void _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await box.put('notifications', value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 24),
          Center(child: Icon(Icons.settings, size: 100, color: kTeal)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "App Preferences",
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 🌙 Dark Mode
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Switch between light and dark mint themes"),
            value: _darkMode,
            activeColor: kTeal,
            onChanged: _toggleDarkMode,
          ),
          const Divider(),

          // 🔔 Notifications
          SwitchListTile(
            title: const Text("Reminders & Notifications"),
            subtitle: const Text("Enable reminders for medicine and hydration"),
            value: _notificationsEnabled,
            activeColor: kTeal,
            onChanged: _toggleNotifications,
          ),
          const Divider(),

          // ℹ️ Info
          ListTile(
            leading: const Icon(Icons.info_outline, color: kTeal),
            title: const Text("About AayuTrack"),
            subtitle: const Text(
              "Monitor your health, hydration, steps, and reminders with AI insights.",
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: kTeal),
            title: const Text("Contact Support"),
            subtitle: const Text("codexwarriors@healthtrack.app"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Support email: codexwarriors@healthtrack.app"),
                ),
              );
            },
          ),

          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                const Text(
                  "Version 1.0.0 (Hackathon Edition)",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  "© 2025 CodeX Warriors",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🩵 Bridge widget for global theme toggling
class MyAppTheme extends InheritedWidget {
  final void Function(bool) toggleTheme;
  const MyAppTheme({
    super.key,
    required this.toggleTheme,
    required super.child,
  });

  static MyAppTheme? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MyAppTheme>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
