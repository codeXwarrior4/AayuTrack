import 'package:flutter/material.dart';
import '../main.dart';
import 'language_screen.dart';
import '../localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLanguageName = "English";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 5),
              child: Text(
                loc?.settings ?? "Settings",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // 🌐 LANGUAGE
            _buildSettingsCard(
              icon: Icons.language,
              iconColor: Colors.teal,
              title: loc?.select_language ?? "Language",
              subtitle: _currentLanguageName,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LanguageScreen(
                      onChangedLocale: (Locale newLocale) {
                        setState(() {
                          _currentLanguageName =
                              _mapLanguageCode(newLocale.languageCode);
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            // 🌙 DARK MODE
            _buildSettingsCard(
              icon: Icons.dark_mode_outlined,
              iconColor: Colors.deepPurple,
              title: loc?.t('dark_mode', 'Dark Mode') ?? 'Dark Mode',
              subtitle: isDark
                  ? loc?.t('enabled', 'Enabled') ?? 'Enabled'
                  : loc?.t('disabled', 'Disabled') ?? 'Disabled',
              onTap: () {
                final theme = MyAppTheme.of(context);
                theme?.toggleTheme(!isDark);
                setState(() {});
              },
            ),

            // 🔔 Notifications
            _buildSettingsCard(
              icon: Icons.notifications_active_outlined,
              iconColor: Colors.orange,
              title:
                  loc?.t('notifications', 'Notifications') ?? 'Notifications',
              subtitle: loc?.t(
                      'manage_notifications', 'Manage alerts & permissions') ??
                  'Manage alerts & permissions',
              onTap: () {},
            ),

            // 🔐 Privacy
            _buildSettingsCard(
              icon: Icons.lock_outline,
              iconColor: Colors.blueGrey,
              title: loc?.t('privacy', 'Privacy') ?? 'Privacy',
              subtitle: loc?.t('data_permissions', 'Data and permissions') ??
                  'Data and permissions',
              onTap: () {},
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                loc?.t('about', 'About') ?? 'About',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            _buildSettingsCard(
              icon: Icons.info_outline,
              iconColor: Colors.indigo,
              title:
                  loc?.t('about_app', 'About AayuTrack') ?? 'About AayuTrack',
              subtitle: "Version 1.0.0",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: iconColor.withOpacity(0.12),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _mapLanguageCode(String code) {
    switch (code) {
      case 'hi':
        return "Hindi";
      case 'mr':
        return "Marathi";
      case 'kn':
        return "Kannada";
      default:
        return "English";
    }
  }
}
