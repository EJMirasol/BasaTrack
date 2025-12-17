import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget displaying a week calendar with completion status
class WeekCalendar extends StatelessWidget {
  final List<bool> weekCompletionStatus; // 7 days: LD-Sat
  final int currentDayIndex; // 0-6 (0=LD, 6=Sat)

  const WeekCalendar({
    super.key,
    required this.weekCompletionStatus,
    required this.currentDayIndex,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['LD', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final isCompleted = index < weekCompletionStatus.length 
              ? weekCompletionStatus[index] 
              : false;
          final isCurrentDay = index == currentDayIndex;
          
          return _buildDayIndicator(
            dayLabels[index],
            isCompleted,
            isCurrentDay,
          );
        }),
      ),
    );
  }

  Widget _buildDayIndicator(String label, bool isCompleted, bool isCurrentDay) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted 
                ? AppColors.success 
                : Colors.grey.shade300,
            border: isCurrentDay
                ? Border.all(color: AppColors.primary, width: 2.5)
                : null,
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
            color: isCurrentDay ? AppColors.primary : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
