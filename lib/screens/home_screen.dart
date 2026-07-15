import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ringrr/data/reminder_provider.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/screens/create_reminder_sheet.dart';
import 'package:ringrr/theme/app_theme.dart';
import 'package:ringrr/widgets/reminder_card.dart';

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
    final pendingTodayOrOverdue = today.length + overdue.length;
    final total = doneCount + pendingTodayOrOverdue;
    final percentage = total > 0 ? (doneCount / total * 100) : 0.0;

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
          const SizedBox(height: 4),
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
          const SizedBox(height: 32),

          // Stats row — naked numbers, no card wrappers
          Row(
            children: [
              // Progress ring — floats on bg
              SizedBox(
                width: 72,
                height: 72,
                child: CustomPaint(
                  painter: _RingPainter(percentage),
                  child: Center(
                    child: Text(
                      '${percentage.round()}%',
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 28),
              _Stat(value: '${today.length + tomorrow.length + upcoming.length}', label: 'PENDING'),
              const SizedBox(width: 28),
              _Stat(value: '$doneCount', label: 'DONE'),
              const SizedBox(width: 28),
              if (overdue.isNotEmpty)
                _Stat(value: '${overdue.length}', label: 'LATE', isAlert: true),
            ],
          ),
          const SizedBox(height: 36),

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
      padding: const EdgeInsets.only(bottom: 28),
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
          const SizedBox(height: 12),
          ...reminders.map((r) => ReminderCard(
            reminder: r,
            isOverdue: isOverdue,
            showDate: showDate,
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

class _RingPainter extends CustomPainter {
  final double percentage;
  _RingPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const strokeWidth = 6.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress
    if (percentage > 0) {
      final sweepAngle = (percentage / 100) * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2,
        sweepAngle,
        false,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.percentage != percentage;
}
