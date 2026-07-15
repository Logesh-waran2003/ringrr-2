import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ringrr/data/reminder_provider.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/theme/app_theme.dart';
import 'package:ringrr/widgets/category_chip.dart';
import 'package:ringrr/widgets/progress_ring.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ReminderProvider.of(context);
    final completed = state.completedReminders;
    final dismissed = state.dismissedReminders;
    final history = [...completed, ...dismissed]
      ..sort((a, b) => (b.completedAt ?? b.scheduledAt)
          .compareTo(a.completedAt ?? a.scheduledAt));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'History',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${history.length} reminder${history.length == 1 ? '' : 's'}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          if (history.isEmpty) ...[
            const SizedBox(height: 120),
            _EmptyState(),
          ] else ...[
            const SizedBox(height: 20),
            _SummaryCard(
              completedCount: completed.length,
              dismissedCount: dismissed.length,
              rate: state.completionRate,
            ),
            const SizedBox(height: 24),
            ...history.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HistoryRow(
                    reminder: r,
                    onDelete: () => state.delete(r.id),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int completedCount;
  final int dismissedCount;
  final double rate;

  const _SummaryCard({
    required this.completedCount,
    required this.dismissedCount,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ProgressRing(
            percentage: rate * 100,
            radius: 36,
            strokeWidth: 8,
            progressColor: const Color(0xFF10B981),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(rate * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'COMPLETION RATE',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount completed · $dismissedCount dismissed',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;

  const _HistoryRow({required this.reminder, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDone = reminder.status == ReminderStatus.completed;
    final dateTime = reminder.completedAt ?? reminder.scheduledAt;
    final dateStr = DateFormat('MMM d, yyyy').format(dateTime);
    final timeStr = DateFormat('h:mm a').format(dateTime);

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.negative.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.negative),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr · $timeStr',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CategoryChip(category: reminder.category),
                ],
              ),
            ),
            _StatusPill(isDone: isDone),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isDone;
  const _StatusPill({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFF10B981).withValues(alpha: 0.14)
            : const Color(0xFF9496AC).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isDone ? 'Done' : 'Dismissed',
        style: TextStyle(
          color: isDone ? const Color(0xFF10B981) : AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textMuted.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.textMuted,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No history yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Completed and dismissed reminders\nwill appear here',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
