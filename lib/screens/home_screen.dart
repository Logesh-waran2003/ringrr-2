import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ringrr/data/reminder_provider.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/screens/create_reminder_sheet.dart';
import 'package:ringrr/theme/app_theme.dart';
import 'package:ringrr/widgets/progress_ring.dart';
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
    final hasPending = overdue.isNotEmpty ||
        today.isNotEmpty ||
        tomorrow.isNotEmpty ||
        upcoming.isNotEmpty;

    final doneCount = completedToday.length;
    final pendingTodayOrOverdue = today.length + overdue.length;
    final total = doneCount + pendingTodayOrOverdue;
    final percentage = total > 0 ? (doneCount / total * 100) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            _greeting,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 22),

          // Stats row
          Row(
            children: [
              // Progress ring card
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ProgressRing(percentage: percentage, radius: 38, strokeWidth: 9),
                    Text(
                      '${percentage.round()}%',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Stat cards column
              Expanded(
                child: Column(
                  children: [
                    _StatCard(
                      value: '${upcoming.length}',
                      label: 'UPCOMING',
                    ),
                    const SizedBox(height: 10),
                    _StatCard(
                      value: '$doneCount',
                      label: 'DONE TODAY',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Reminder sections or empty state
          if (!hasPending)
            _EmptyState()
          else ...[
            if (overdue.isNotEmpty)
              _ReminderSection(
                label: 'OVERDUE',
                reminders: overdue,
                isOverdue: true,
              ),
            if (today.isNotEmpty)
              _ReminderSection(label: 'TODAY', reminders: today),
            if (tomorrow.isNotEmpty)
              _ReminderSection(
                label: 'TOMORROW',
                reminders: tomorrow,
                showDate: true,
              ),
            if (upcoming.isNotEmpty)
              _ReminderSection(
                label: 'UPCOMING',
                reminders: upcoming,
                showDate: true,
              ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderSection extends StatelessWidget {
  final String label;
  final List<Reminder> reminders;
  final bool isOverdue;
  final bool showDate;

  const _ReminderSection({
    required this.label,
    required this.reminders,
    this.isOverdue = false,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          ...reminders.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReminderCard(
                reminder: r,
                isOverdue: isOverdue,
                showDate: showDate,
              ),
            ),
          ),
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
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'All clear',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No pending reminders',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => showCreateReminderSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Add a reminder',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
