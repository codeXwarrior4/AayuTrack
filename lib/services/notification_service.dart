// lib/services/notification_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ------------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------------
  static Future<void> init() async {
    tz.initializeTimeZones();

    await Hive.initFlutter();
    await Hive.openBox('aayutrack_reminders');

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔔 Notification tapped: ${response.payload}");
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _createMainChannel();
      await _createDailyChannel();
    }

    await requestPermission();
    await _rescheduleSavedReminders();
  }

  // ------------------------------------------------------------------
  // PERMISSION FIXED for flutter_local_notifications 17.2.4
  // ------------------------------------------------------------------
  static Future<void> requestPermission() async {
    // ANDROID 13+ Notification permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // iOS permissions
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // ------------------------------------------------------------------
  // CHANNELS
  // ------------------------------------------------------------------
  static Future<void> _createMainChannel() async {
    const channel = AndroidNotificationChannel(
      'aayutrack_reminders',
      'AayuTrack Health Alerts',
      description: 'Medicine, hydration & health alerts',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      showBadge: true,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);
  }

  static Future<void> _createDailyChannel() async {
    const channel = AndroidNotificationChannel(
      'aayutrack_daily',
      'AayuTrack Daily Reminders',
      description: 'Daily scheduled reminders',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);
  }

  // ------------------------------------------------------------------
  // DETAILS FOR BOTH DAILY & ONCE
  // ------------------------------------------------------------------
  static NotificationDetails _alarmDetails(String channelId, String name) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        name,
        channelDescription: 'AayuTrack Alerts',
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        playSound: true,
        enableVibration: true,
        ticker: 'AayuTrack Reminder',
        icon: '@mipmap/ic_launcher',
        visibility: NotificationVisibility.public,
      ),
      iOS: const DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  // ------------------------------------------------------------------
  // SHOW INSTANT
  // ------------------------------------------------------------------
  static Future<void> showInstant({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      _alarmDetails('aayutrack_reminders', "AayuTrack Health Alerts"),
      payload: payload,
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async =>
      showInstant(title: title, body: body);

  // ------------------------------------------------------------------
  // ONE-TIME SCHEDULE
  // ------------------------------------------------------------------
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
      _alarmDetails('aayutrack_reminders', "AayuTrack Health Alerts"),
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

  // ------------------------------------------------------------------
  // DAILY SCHEDULE
  // ------------------------------------------------------------------
  static Future<void> scheduleDaily({
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final id = time.hour * 100 + time.minute;

    final now = DateTime.now();
    DateTime scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final box = Hive.box('aayutrack_reminders');

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduled, tz.local),
      _alarmDetails('aayutrack_daily', "AayuTrack Daily Reminders"),
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

  // ------------------------------------------------------------------
  // RESTORE ON RESTART
  // ------------------------------------------------------------------
  static Future<void> _rescheduleSavedReminders() async {
    final box = Hive.box('aayutrack_reminders');

    for (final r in box.values) {
      try {
        if (r['type'] == 'daily') {
          await scheduleDaily(
            title: r['title'],
            body: r['body'],
            time: TimeOfDay(hour: r['hour'], minute: r['minute']),
          );
        } else if (r['type'] == 'once') {
          final t = DateTime.parse(r['time']);
          if (t.isAfter(DateTime.now())) {
            await schedule(title: r['title'], body: r['body'], time: t);
          } else {
            await box.delete(r['id']);
          }
        }
      } catch (e) {
        debugPrint("⚠ Reschedule error: $e");
      }
    }
  }

  // ------------------------------------------------------------------
  // CANCEL ALL
  // ------------------------------------------------------------------
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    await Hive.box('aayutrack_reminders').clear();
  }
}
