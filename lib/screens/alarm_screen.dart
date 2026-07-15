import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:ringrr/data/reminder_provider.dart';
import 'package:ringrr/models/reminder.dart';
import 'package:ringrr/services/alarm_ringer.dart';
import 'package:ringrr/theme/app_theme.dart';
import 'package:ringrr/widgets/category_chip.dart';

class AlarmScreen extends StatefulWidget {
  final Reminder reminder;
  const AlarmScreen({super.key, required this.reminder});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    AlarmRinger.start();

    Future.delayed(const Duration(milliseconds: 500), () {
      final tts = FlutterTts();
      tts.speak('Reminder: ${widget.reminder.title}. ${widget.reminder.description}');
    });
  }

  @override
  void dispose() {
    AlarmRinger.stop();
    _pulseController.dispose();
    super.dispose();
  }

  void _snooze() {
    AlarmRinger.stop();
    final state = ReminderProvider.of(context);
    state.update(widget.reminder.copyWith(
      scheduledAt: DateTime.now().add(const Duration(minutes: 5)),
    ));
    Navigator.of(context).pop();
  }

  void _dismiss() {
    AlarmRinger.stop();
    final state = ReminderProvider.of(context);
    state.dismiss(widget.reminder.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final time = DateFormat('h:mm').format(now);
    final ampm = DateFormat('a').format(now);
    final date = DateFormat('EEEE, MMMM d').format(now).toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.44),
            radius: 0.7,
            colors: [
              AppColors.primary.withValues(alpha: 0.28),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // RINGING label
                Row(
                  children: [
                    Icon(Icons.notifications_active,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'RINGING',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                // Pulsing rings
                Center(child: _PulsingRings(controller: _pulseController)),
                const SizedBox(height: 36),
                // Time
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 72,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ampm,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    date,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Reminder card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.reminder.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.reminder.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.reminder.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      CategoryChip(category: widget.reminder.category),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _snooze,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time,
                                  color: AppColors.bg, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Snooze 5 min',
                                style: TextStyle(
                                  color: AppColors.bg,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: AppColors.textPrimary, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              'Dismiss',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingRings extends StatelessWidget {
  final AnimationController controller;
  const _PulsingRings({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ring 1
              _buildRing(controller.value),
              // Ring 2 — staggered by 0.5
              _buildRing((controller.value + 0.5) % 1.0),
              // Center circle
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: AppColors.bg,
                  size: 36,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRing(double progress) {
    final scale = 1.0 + (0.55 * progress);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
