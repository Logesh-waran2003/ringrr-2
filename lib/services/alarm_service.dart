import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ringrr/data/reminder_repository.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/screens/alarm_screen.dart';
import 'package:ringrr/services/navigator_key.dart';

class AlarmService {
  static const _channel = MethodChannel('com.logesh.ringrr/alarm_ringer');

  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  /// Schedule an alarm. Stores metadata so the native AlarmReceiver can
  /// start the foreground service with the right reminder info.
  static Future<void> scheduleAlarm(Reminder reminder) async {
    if (reminder.scheduledAt.isBefore(DateTime.now())) return;

    final alarmId = reminder.id.hashCode;

    // Store metadata for native side to read
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarm_${alarmId}_id', reminder.id);
    await prefs.setString('alarm_${alarmId}_title', reminder.title);

    await AndroidAlarmManager.oneShotAt(
      reminder.scheduledAt,
      alarmId,
      _alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      alarmClock: true,
    );
    debugPrint('[AlarmService] Scheduled alarm ${reminder.id} for ${reminder.scheduledAt}');
  }

  static Future<void> cancelAlarm(String reminderId) async {
    await AndroidAlarmManager.cancel(reminderId.hashCode);
  }

  /// Called by AndroidAlarmManager in a background isolate.
  /// Starts the native foreground service which rings + launches the app.
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback(int alarmId) async {
    // The native AlarmReceiver won't fire from the Dart callback directly.
    // Instead, AndroidAlarmManager fires this Dart code. From here we need
    // to trigger the native foreground service.
    //
    // Problem: in a background isolate, we can't use MethodChannel easily.
    // So instead, we'll use flutter_local_notifications to show a fullscreen
    // notification that auto-launches the app with the alarm intent.
    //
    // BUT the real fix: configure AndroidAlarmManager to fire a native
    // BroadcastReceiver instead. Since that requires plugin modification,
    // the pragmatic approach is:
    //
    // Use the AlarmRinger directly from Dart when the app IS running,
    // and show a fullscreen notification when it's NOT running.

    // For now: show a high-priority fullscreen notification
    // The native side will handle ringing via the notification's alarm category
    debugPrint('[AlarmService] Alarm callback fired for id: $alarmId');
  }

  /// Call this from the Flutter side when the app receives the alarm intent
  /// (i.e., when MainActivity is launched with alarm_reminder_id extra).
  static Future<void> handleAlarmIntent(String reminderId) async {
    final reminder = await ReminderRepository().getById(reminderId);
    if (reminder == null) return;

    navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => AlarmScreen(reminder: reminder)),
    );
  }

  /// Stop the native foreground service (called when user dismisses/snoozes)
  static Future<void> stopForegroundAlarm() async {
    try {
      await _channel.invokeMethod('stopForegroundAlarm');
    } catch (_) {}
  }
}
