import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:animations/animations.dart';

import 'theme.dart';
import 'services/notification_service.dart';

// Screens
import 'screens/dashboard_screen.dart';
import 'screens/ai_checkup_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/report_analytics_screen.dart'; // New Analytics Page

/// ---------------------------------------------------------------------------
/// 🩺 ENTRY POINT — Initialize Hive + Notifications + App
/// ---------------------------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('aayutrack_box');
  await NotificationService.init();

  runApp(const RootApp());
}

/// ---------------------------------------------------------------------------
/// 🌿 ROOT APP — handles theme switching globally
/// ---------------------------------------------------------------------------
class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  bool _darkMode = Hive.box(
    'aayutrack_box',
  ).get('darkMode', defaultValue: false);

  void _toggleTheme(bool dark) {
    setState(() => _darkMode = dark);
    Hive.box('aayutrack_box').put('darkMode', dark);
  }

  @override
  Widget build(BuildContext context) {
    return MyAppTheme(
      toggleTheme: _toggleTheme,
      child: MaterialApp(
        title: 'AayuTrack Pro',
        debugShowCheckedModeBanner: false,
        theme: buildAayuTrackLightTheme(),
        darkTheme: buildAayuTrackDarkTheme(),
        themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 💫 SPLASH SCREEN — Animated Lottie intro
/// ---------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLogo() {
    try {
      return Lottie.asset(
        'assets/animations/health.json',
        width: 220,
        repeat: true,
        controller: _controller,
      );
    } catch (_) {
      return const Icon(Icons.favorite, size: 120, color: kTeal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(height: 20),
            Text(
              'AayuTrack',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: kTeal,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Digital Health Partner',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: kTeal, strokeWidth: 2.4),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 🧭 MAIN SCAFFOLD — Bottom Navigation with Transitions
/// ---------------------------------------------------------------------------
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    AiCheckupScreen(),
    RemindersScreen(),
    ReportAnalyticsScreen(), // New Analytics page
    ProfileScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'AI Checkup',
    'Reminders',
    'Analytics', // New page label
    'Profile',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 1.5,
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation, secondaryAnimation) =>
            FadeScaleTransition(animation: animation, child: child),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: colorScheme.secondary.withOpacity(0.4),
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Theme.of(context).cardColor,
          elevation: 4,
          selectedIndex: _currentIndex,
          animationDuration: const Duration(milliseconds: 300),
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.health_and_safety_outlined),
              selectedIcon: Icon(Icons.health_and_safety),
              label: 'AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.alarm_outlined),
              selectedIcon: Icon(Icons.alarm),
              label: 'Reminders',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined), // Analytics Icon
              selectedIcon: Icon(Icons.analytics),
              label: 'Analytics', // Label for analytics
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
