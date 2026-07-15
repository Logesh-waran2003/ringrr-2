import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:ringrr/data/reminder_repository.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/screens/alarm_screen.dart';
import 'package:ringrr/services/navigator_key.dart';

class AlarmService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    // ponytail: hardcoded to Asia/Kolkata. Ceiling: breaks for users outside IST.
    // Upgrade path: add flutter_timezone package and call FlutterTimezone.getLocalTimezone().
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onTap,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(const AndroidNotificationChannel(
      'ringrr_alarms',
      'Reminders',
      importance: Importance.max,
    ));

    // Android 13+ requires runtime permission for notifications
    await android?.requestNotificationsPermission();
    // Android 12+ requires explicit permission for exact alarms
    await android?.requestExactAlarmsPermission();
    // Android 14+ requires permission for full-screen intents
    await android?.requestFullScreenIntentPermission();
  }

  static Future<void> scheduleAlarm(Reminder reminder) async {
    final scheduledDate = tz.TZDateTime.from(reminder.scheduledAt, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      'ringrr_alarms',
      'Reminders',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id: reminder.id.hashCode,
      title: reminder.title,
      body: reminder.description,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: reminder.id,
    );
  }

  static Future<void> cancelAlarm(String reminderId) async {
    await _plugin.cancel(id: reminderId.hashCode);
  }

  static void _onTap(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) return;

    final reminder = await ReminderRepository().getById(payload);
    if (reminder == null) return;

    navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => AlarmScreen(reminder: reminder)),
    );
  }
}
