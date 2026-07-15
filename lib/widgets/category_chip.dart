import 'package:flutter/material.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final ReminderCategory category;

  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            category.label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
