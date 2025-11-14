import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// ---------------------------------------------------------------------------
/// 🔔 NotificationService — handles instant + scheduled + daily reminders
/// ---------------------------------------------------------------------------
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    await Hive.initFlutter();
    await Hive.openBox('aayutrack_reminders');

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const settings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔔 Notification tapped: ${response.payload}");
      },
    );

    if (!kIsWeb && Platform.isAndroid) await _createChannel();
    await _rescheduleSavedReminders();
  }

  static Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      'aayutrack_reminders',
      'AayuTrack Health Alerts',
      description: 'Reminders for medicine, hydration, and activity tracking.',
      importance: Importance.max,
    );
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(channel);
  }

  /// 🚀 Instant notification
  static Future<void> showInstant({
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'aayutrack_reminders',
        'AayuTrack Health Alerts',
        channelDescription: 'Instant health reminders',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// 🕒 Schedule one-time notification
  static Future<void> schedule({
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final id = time.millisecondsSinceEpoch ~/ 1000;
    final box = Hive.box('aayutrack_reminders');

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'aayutrack_reminders',
          'AayuTrack Health Alerts',
          channelDescription: 'Scheduled notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    await box.put(id, {
      'id': id,
      'title': title,
      'body': body,
      'time': time.toIso8601String(),
      'type': 'once',
    });
  }

  /// 🔁 Daily reminder
  static Future<void> scheduleDaily({
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final id = time.hour * 100 + time.minute;
    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final box = Hive.box('aayutrack_reminders');

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduled.isBefore(now)
            ? scheduled.add(const Duration(days: 1))
            : scheduled,
        tz.local,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'aayutrack_daily',
          'AayuTrack Daily Reminders',
          channelDescription: 'Repeating daily health reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    await box.put(id, {
      'id': id,
      'title': title,
      'body': body,
      'hour': time.hour,
      'minute': time.minute,
      'type': 'daily',
    });
  }

  static Future<void> _rescheduleSavedReminders() async {
    final box = Hive.box('aayutrack_reminders');
    for (final reminder in box.values) {
      try {
        if (reminder['type'] == 'daily') {
          await scheduleDaily(
            title: reminder['title'],
            body: reminder['body'],
            time: TimeOfDay(hour: reminder['hour'], minute: reminder['minute']),
          );
        } else if (reminder['type'] == 'once') {
          final t = DateTime.parse(reminder['time']);
          if (t.isAfter(DateTime.now())) {
            await schedule(
              title: reminder['title'],
              body: reminder['body'],
              time: t,
            );
          } else {
            await box.delete(reminder['id']);
          }
        }
      } catch (e) {
        debugPrint("⚠️ Reschedule error: $e");
      }
    }
  }

  /// ❌ Cancel all reminders
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    await Hive.box('aayutrack_reminders').clear();
  }
}
