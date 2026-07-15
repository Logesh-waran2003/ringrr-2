import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ringrr/data/reminder_provider.dart';
import 'package:ringrr/data/reminder_state.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/screens/create_reminder_sheet.dart';
import 'package:ringrr/theme/app_theme.dart';
import 'package:ringrr/widgets/analog_clock.dart';
import 'package:ringrr/widgets/reminder_card.dart';

Reminder? _nextReminder(ReminderState state) {
  final all = [...state.todayReminders, ...state.tomorrowReminders, ...state.upcomingReminders];
  if (all.isEmpty) return null;
  all.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return all.first;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = ReminderProvider.of(context);
    final overdue = state.overdueReminders;
    final today = state.todayReminders;
    final tomorrow = state.tomorrowReminders;
    final upcoming = state.upcomingReminders;
    final completedToday = state.completedToday;
    final hasPending = overdue.isNotEmpty || today.isNotEmpty || tomorrow.isNotEmpty || upcoming.isNotEmpty;

    final doneCount = completedToday.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 72, 22, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            _greeting,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: const TextStyle(
              fontFamily: AppTheme.displayFont,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          // Overdue pulse indicator
          if (overdue.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const _PulsingDot(),
                const SizedBox(width: 6),
                Text(
                  '${overdue.length} overdue',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),

          // Analog clock hero
          Center(child: AnalogClock(
            size: 140,
            reminderTimes: [
              ...state.todayReminders.map((r) => r.scheduledAt),
              ...state.tomorrowReminders.map((r) => r.scheduledAt),
            ].take(6).toList(), // max 6 dots to avoid clutter
          )),
          const SizedBox(height: 16),
          // Next alarm countdown
          if (_nextReminder(state) != null) ...[
            Center(
              child: _NextAlarmLabel(reminder: _nextReminder(state)!),
            ),
            const SizedBox(height: 24),
          ],
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Stat(value: '${today.length + tomorrow.length + upcoming.length}', label: 'PENDING'),
              const SizedBox(width: 32),
              _Stat(value: '$doneCount', label: 'DONE'),
              if (overdue.isNotEmpty) ...[
                const SizedBox(width: 32),
                _Stat(value: '${overdue.length}', label: 'LATE', isAlert: true),
              ],
            ],
          ),
          const SizedBox(height: 40),

          // Sections or empty state
          if (!hasPending)
            _EmptyState()
          else ...[
            if (overdue.isNotEmpty)
              _Section(label: 'OVERDUE', reminders: overdue, isOverdue: true),
            if (today.isNotEmpty)
              _Section(label: 'TODAY', reminders: today),
            if (tomorrow.isNotEmpty)
              _Section(label: 'TOMORROW', reminders: tomorrow, showDate: true),
            if (upcoming.isNotEmpty)
              _Section(label: 'UPCOMING', reminders: upcoming, showDate: true),
          ],
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        // ponytail: triangle wave for smooth pulse
        final t = _ctrl.value < 0.5 ? _ctrl.value * 2 : (1 - _ctrl.value) * 2;
        final scale = 1.0 + t * 0.3;
        final opacity = 1.0 - t * 0.25;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final bool isAlert;

  const _Stat({required this.value, required this.label, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isAlert ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final List<Reminder> reminders;
  final bool isOverdue;
  final bool showDate;

  const _Section({required this.label, required this.reminders, this.isOverdue = false, this.showDate = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isOverdue ? AppColors.primary : AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ...reminders.asMap().entries.map((entry) => ReminderCard(
            reminder: entry.value,
            isOverdue: isOverdue,
            showDate: showDate,
            index: entry.key,
          )),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            const Text(
              'All clear',
              style: TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No pending reminders',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => showCreateReminderSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Add a reminder',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextAlarmLabel extends StatelessWidget {
  final Reminder reminder;
  const _NextAlarmLabel({required this.reminder});

  String _relativeTime() {
    final diff = reminder.scheduledAt.difference(DateTime.now());
    if (diff.isNegative) return 'now';
    if (diff.inMinutes < 60) return 'in ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'in ${diff.inHours}h ${diff.inMinutes % 60}m';
    return 'in ${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          reminder.title,
          style: const TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _relativeTime(),
          style: const TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
