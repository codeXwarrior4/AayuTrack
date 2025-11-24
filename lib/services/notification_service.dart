import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _exactAlarmChannel =
      MethodChannel('app.channel/exact_alarms');

  static const String reminderBox = 'aayutrack_reminders';

  // ================= INIT =================

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    if (!Hive.isBoxOpen(reminderBox)) {
      await Hive.openBox(reminderBox);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings);

    if (!kIsWeb && Platform.isAndroid) {
      await _createChannels();
    }

    await requestPermission();
  }

  // Called from main.dart on app start
  static Future<void> triggerReschedule() async {
    await _rescheduleSavedReminders();
  }

  // ================= PERMISSIONS =================

  static Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<bool> _canScheduleExact() async {
    if (!Platform.isAndroid) return true;

    try {
      final result =
          await _exactAlarmChannel.invokeMethod<bool>('canScheduleExactAlarms');
      return result ?? false;
    } catch (_) {
      return true;
    }
  }

  static Future<void> _requestExactPermission() async {
    if (!Platform.isAndroid) return;

    try {
      await _exactAlarmChannel.invokeMethod('requestExactAlarmsPermission');
    } catch (_) {}
  }

  // ================= CHANNEL =================

  static Future<void> _createChannels() async {
    const channel = AndroidNotificationChannel(
      'aayu_alarm',
      'Alarm Reminders',
      description: 'High priority alarm notifications',
      importance: Importance.max,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'aayu_alarm',
        'Alarm Reminders',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );
  }

  // ================= INSTANT ALARM + POPUP =================

  static Future<void> showAlarmPopupAndNotification({
    required BuildContext context,
    required String title,
    required String body,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _plugin.show(id, title, body, _details());

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.alarm, color: Colors.red),
              SizedBox(width: 8),
              Text("ALARM"),
            ],
          ),
          content: Text(body),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("DISMISS"),
            ),
          ],
        ),
      );
    }
  }

  // ================= ONE TIME SCHEDULE =================

  static Future<void> schedule({
    required String title,
    required String body,
    required DateTime time,
  }) async {
    if (!await _canScheduleExact()) {
      await _requestExactPermission();
      return;
    }

    final id = time.millisecondsSinceEpoch ~/ 1000;
    final box = Hive.box(reminderBox);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await box.put(id, {
      'id': id,
      'title': title,
      'body': body,
      'time': time.toIso8601String(),
      'type': 'once',
    });
  }

  // ================= DAILY =================

  static Future<void> scheduleDaily({
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    if (!await _canScheduleExact()) {
      await _requestExactPermission();
      return;
    }

    final now = DateTime.now();
    DateTime schedule = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (schedule.isBefore(now)) {
      schedule = schedule.add(const Duration(days: 1));
    }

    final id = time.hour * 100 + time.minute;
    final box = Hive.box(reminderBox);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(schedule, tz.local),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
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

  // ================= RESCHEDULE =================

  static Future<void> _rescheduleSavedReminders() async {
    final box = Hive.box(reminderBox);

    for (final r in box.values) {
      try {
        if (r['type'] == 'daily') {
          await scheduleDaily(
            title: r['title'],
            body: r['body'],
            time: TimeOfDay(hour: r['hour'], minute: r['minute']),
          );
        } else {
          final t = DateTime.parse(r['time']);
          if (t.isAfter(DateTime.now())) {
            await schedule(
              title: r['title'],
              body: r['body'],
              time: t,
            );
          }
        }
      } catch (e) {
        debugPrint("Reschedule error: $e");
      }
    }
  }

  // ================= CANCEL =================

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
    await Hive.box(reminderBox).delete(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    await Hive.box(reminderBox).clear();
  }
}
