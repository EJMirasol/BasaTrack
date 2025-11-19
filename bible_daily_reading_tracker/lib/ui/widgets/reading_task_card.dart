import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/reading_task.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'animated_check.dart';

/// Card widget for displaying a reading task
class ReadingTaskCard extends StatelessWidget {
  final ReadingTask task;
  final ValueChanged<bool>? onToggle;

  const ReadingTaskCard({
    super.key,
    required this.task,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: AppConstants.mediumAnimation,
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing,
        vertical: 8,
      ),
      child: Material(
        elevation: task.isCompleted ? 1 : AppConstants.cardElevation,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        shadowColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.shadowLight
            : AppColors.shadowDark,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onToggle?.call(!task.isCompleted);
          },
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: AnimatedContainer(
            duration: AppConstants.mediumAnimation,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              color: task.isCompleted
                  ? AppColors.success.withOpacity(0.1)
                  : theme.cardColor,
              border: Border.all(
                color: task.isCompleted
                    ? AppColors.success.withOpacity(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Animated Checkbox
                AnimatedCheck(
                  isChecked: task.isCompleted,
                  onChanged: onToggle,
                  size: 28,
                ),
                
                const SizedBox(width: 16),
                
                // Reading Reference
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.reference,
                        style: theme.textTheme.titleLarge?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.textSecondary,
                          decorationThickness: 2,
                          color: task.isCompleted
                              ? AppColors.textSecondary
                              : theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      if (task.isCompleted && task.completedAt != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Book Icon
                Icon(
                  Icons.menu_book_rounded,
                  color: task.isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
