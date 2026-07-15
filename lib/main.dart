import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ringrr/data/reminder_provider.dart';
import 'package:ringrr/data/reminder_state.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/screens/app_shell.dart';
import 'package:ringrr/services/alarm_service.dart';
import 'package:ringrr/services/navigator_key.dart';
import 'package:ringrr/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await AlarmService.init();
  await _seedIfEmpty();

  final state = ReminderState();
  await state.load();

  runApp(RingrrApp(state: state));
}

Future<void> _seedIfEmpty() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getStringList('reminders')?.isNotEmpty ?? false) return;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final state = ReminderState();

  final seeds = [
    // Overdue
    Reminder(
      id: '1', title: 'Submit expense report', description: 'Q3 travel receipts to finance',
      category: ReminderCategory.work, scheduledAt: today.add(const Duration(hours: 19, minutes: 30)),
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    Reminder(
      id: '2', title: 'Take vitamins', description: 'Morning supplements',
      category: ReminderCategory.health, scheduledAt: today.add(const Duration(hours: 21, minutes: 15)),
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    // Today
    Reminder(
      id: '3', title: 'Call mom', description: 'Check in about the weekend',
      category: ReminderCategory.personal, scheduledAt: today.add(const Duration(hours: 23, minutes: 25)),
      createdAt: now,
    ),
    // Tomorrow
    Reminder(
      id: '4', title: 'Team standup notes', description: 'Write up async summary',
      category: ReminderCategory.work, scheduledAt: tomorrow.add(const Duration(hours: 2, minutes: 10)),
      createdAt: now,
    ),
    Reminder(
      id: '5', title: 'Water the plants', description: 'Living room + balcony',
      category: ReminderCategory.health, scheduledAt: tomorrow.add(const Duration(hours: 23, minutes: 50)),
      createdAt: now,
    ),
    // Upcoming
    Reminder(
      id: '6', title: 'Book dentist appointment', description: 'Annual cleaning',
      category: ReminderCategory.health, scheduledAt: today.add(const Duration(days: 4, hours: 21, minutes: 50)),
      createdAt: now,
    ),
    Reminder(
      id: '7', title: 'Plan weekend trip', description: 'Look at cabins near the lake',
      category: ReminderCategory.social, scheduledAt: today.add(const Duration(days: 6, hours: 21, minutes: 50)),
      createdAt: now,
    ),
  ];

  for (final r in seeds) {
    await state.add(r);
  }
}

class RingrrApp extends StatelessWidget {
  final ReminderState state;

  const RingrrApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ReminderProvider(
      state: state,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Ringrr',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const AppShell(),
      ),
    );
  }
}
