import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reading_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../widgets/reading_task_card.dart';

/// Screen showing backlog of missed/incomplete past schedules
class BacklogScreen extends StatelessWidget {
  const BacklogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingProvider = context.watch<ReadingProvider>();

    final missedSchedules = readingProvider.getMissedSchedules();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Backlogs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: missedSchedules.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All Caught Up!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have no missed readings',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: missedSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = missedSchedules[index];
                  final incompleteTasks = schedule.tasks
                      .where((task) => !task.isCompleted)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              app_date_utils.DateUtils.formatFullDate(
                                schedule.date,
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${incompleteTasks.length}/${schedule.totalCount}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Incomplete Tasks (Read-only in backlog)
                      ...incompleteTasks.map((task) {
                        return ReadingTaskCard(
                          task: task,
                          // No onToggle - tasks are read-only in backlog
                        );
                      }),
                      
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
