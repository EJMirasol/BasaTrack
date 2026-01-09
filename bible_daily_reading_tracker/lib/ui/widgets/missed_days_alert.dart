import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Alert widget shown when user has missed reading days
class MissedDaysAlert extends StatelessWidget {
  final int missedDays;
  final VoidCallback? onDismiss;

  const MissedDaysAlert({
    required this.missedDays, super.key,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (missedDays <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacing),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Warning Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gentle Reminder',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  missedDays == 1
                      ? 'You missed for 1 day. Let\'s get back on track!'
                      : 'You have missed for $missedDays days. Don\'t give up!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Dismiss Button
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onDismiss,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
