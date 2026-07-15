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

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'ringrr_alarms',
          'Reminders',
          importance: Importance.max,
        ));
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
