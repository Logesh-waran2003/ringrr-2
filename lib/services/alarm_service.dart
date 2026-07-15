import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ringrr/data/reminder_repository.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/screens/alarm_screen.dart';
import 'package:ringrr/services/navigator_key.dart';

class AlarmService {
  static final _notifPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await AndroidAlarmManager.initialize();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotifTap,
    );

    final android = _notifPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      await android.createNotificationChannel(const AndroidNotificationChannel(
        'ringrr_alarms',
        'Reminders',
        importance: Importance.max,
      ));
      await android.requestNotificationsPermission();
    }
  }

  /// Schedule an alarm using AndroidAlarmManager (fires even in Doze)
  static Future<void> scheduleAlarm(Reminder reminder) async {
    if (reminder.scheduledAt.isBefore(DateTime.now())) return;

    await AndroidAlarmManager.oneShotAt(
      reminder.scheduledAt,
      reminder.id.hashCode,
      _alarmFired,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      alarmClock: true,
    );
  }

  /// Cancel a scheduled alarm
  static Future<void> cancelAlarm(String reminderId) async {
    await AndroidAlarmManager.cancel(reminderId.hashCode);
  }

  /// Callback fired by AndroidAlarmManager when alarm time arrives.
  /// Runs in an isolate — show notification to bring user back to app.
  @pragma('vm:entry-point')
  static Future<void> _alarmFired(int id) async {
    // Show a high-priority notification that brings the user to the alarm screen
    const androidDetails = AndroidNotificationDetails(
      'ringrr_alarms',
      'Reminders',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
    );
    const details = NotificationDetails(android: androidDetails);

    // We need to init the notification plugin in this isolate
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(settings: initSettings);

    // Find which reminder this alarm is for
    final repo = ReminderRepository();
    final all = await repo.getAll();
    final reminder = all.where((r) => r.id.hashCode == id).firstOrNull;

    await plugin.show(
      id: id,
      title: reminder?.title ?? 'Reminder',
      body: reminder?.description ?? 'Time for your reminder',
      notificationDetails: details,
      payload: reminder?.id ?? '',
    );
  }

  /// Handle notification tap — navigate to alarm screen
  static void _onNotifTap(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final reminder = await ReminderRepository().getById(payload);
    if (reminder == null) return;

    navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => AlarmScreen(reminder: reminder)),
    );
  }
}
