import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ringrr/data/reminder_provider.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/screens/create_reminder_sheet.dart';
import 'package:ringrr/theme/app_theme.dart';
import 'package:ringrr/widgets/category_chip.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final bool isOverdue;
  final bool showDate; // show date label for tomorrow/upcoming

  const ReminderCard({
    super.key,
    required this.reminder,
    this.isOverdue = false,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = ReminderProvider.of(context);

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.3},
      onDismissed: (_) => state.delete(reminder.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.negative,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => showEditReminderSheet(context, reminder),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF151821), Color(0xFF0E1017)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Time column
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(reminder.scheduledAt),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isOverdue
                            ? AppColors.negative
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (showDate) ...[
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d').format(reminder.scheduledAt),
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (reminder.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        reminder.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    CategoryChip(category: reminder.category),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Complete button
              GestureDetector(
                onTap: () => state.markComplete(reminder.id),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1A1D28),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF5A5D72),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
