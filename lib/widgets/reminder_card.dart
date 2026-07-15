import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ringrr/data/reminder_provider.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/screens/create_reminder_sheet.dart';
import 'package:ringrr/theme/app_theme.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final bool isOverdue;
  final bool showDate;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.isOverdue = false,
    this.showDate = false,
  });

  static const _categoryAbbr = {
    ReminderCategory.personal: 'PER',
    ReminderCategory.work: 'WRK',
    ReminderCategory.health: 'HTH',
    ReminderCategory.social: 'SOC',
  };

  @override
  Widget build(BuildContext context) {
    final state = ReminderProvider.of(context);
    final timeStr = DateFormat('h:mm a').format(reminder.scheduledAt);

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => state.delete(reminder.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.primary.withValues(alpha: 0.15),
        child: const Icon(Icons.delete_outline, color: AppColors.primary, size: 20),
      ),
      child: GestureDetector(
        onTap: () => showEditReminderSheet(context, reminder),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: Row(
            children: [
              // Time
              SizedBox(
                width: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    if (showDate)
                      Text(
                        DateFormat('EEE, MMM d').format(reminder.scheduledAt),
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (reminder.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        reminder.description,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Category abbreviation — monospace 3-letter label
              Text(
                _categoryAbbr[reminder.category] ?? '',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 12),
              // Complete button
              GestureDetector(
                onTap: () => state.markComplete(reminder.id),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: const Icon(Icons.check, size: 14, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
