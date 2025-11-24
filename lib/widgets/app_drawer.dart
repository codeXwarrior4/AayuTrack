import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final Box _box = Hive.box('aayutrack_box');

  void _logout(BuildContext context) {
    // Clear user state (assuming these keys control login state)
    _box.delete('loggedIn');
    _box.delete('onboarded');

    // Navigate back to the landing screen and clear the navigation stack
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/landing', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Fetch profile data for the header
    final profile =
        Map<String, dynamic>.from(_box.get('profile', defaultValue: {}));
    final name = profile['name'] ?? 'User';

    return Drawer(
      child: Column(
        children: <Widget>[
          // Drawer Header
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: const Text("Stay consistent"), // Placeholder tagline
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Color(0xFF00A389), // kTeal color
                size: 40,
              ),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF00A389), // kTeal color
            ),
          ),

          // Menu Options
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),

          // <<< SMARTWATCH OPTION: ONLY IN DRAWER >>>
          ListTile(
            leading: const Icon(Icons.watch_outlined),
            title: const Text('Smartwatch Sync'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushNamed(context, '/smartwatch');
            },
          ),
          // <<< END SMARTWATCH OPTION >>>

          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Progress'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to the new Progress screen
              Navigator.pushNamed(context, '/progress');
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_copy_outlined),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reports');
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_hospital_outlined),
            title: const Text('Telemedicine'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/telemedicine');
            },
          ),
          ListTile(
            leading: const Icon(Icons.emergency_outlined),
            title: const Text('Emergency'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/emergency');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
