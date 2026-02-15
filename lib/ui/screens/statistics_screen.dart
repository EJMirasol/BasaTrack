import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reading_provider.dart';
import '../../core/theme/app_colors.dart';

/// Screen showing reading statistics and a summary of missed readings
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final readingProvider = context.watch<ReadingProvider>();

    final totalCompletedTasks = readingProvider.getTotalCompletedTasksCount();
    final totalWeekStreaks = readingProvider.getTotalWeekStreaksCount();
    final totalBacklogs = readingProvider.getIncompleteMissedDaysCount();
    final longestStreak = readingProvider.getLongestStreak();
    final totalDaysRead = readingProvider.getTotalDaysRead();
    final weekStatus = readingProvider.getWeekCompletionStatus();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              title: Text(
                'Stats',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 0,
              centerTitle: true,
              floating: true,
              pinned: false,
            ),
            // Statistics Summary Cards
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildListDelegate([
                  _buildStatCard(
                    context,
                    title: 'Backlogs',
                    value: totalBacklogs.toString(),
                    icon: Icons.history_toggle_off,
                    color: Colors.orange.shade700,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Completed',
                    value: totalCompletedTasks.toString(),
                    icon: Icons.task_alt,
                    color: AppColors.success,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Week Streaks',
                    value: totalWeekStreaks.toString(),
                    icon: Icons.auto_awesome,
                    color: Colors.purple.shade700,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Personal Best',
                    value: '$longestStreak Days',
                    icon: Icons.emoji_events,
                    color: Colors.amber.shade700,
                  ),
                ]),
              ),
            ),

            // Weekly Overview Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildWeeklyOverview(context, weekStatus),
              ),
            ),

            // Progress Section (Always visible)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildBibleProgressCard(context, readingProvider),
              ),
            ),

            // Reading Activity Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: _buildStatCard(
                  context,
                  title: 'Total Days Read',
                  value: '$totalDaysRead Days',
                  icon: Icons.calendar_today,
                  color: Colors.blue.shade700,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 12),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBibleProgressCard(BuildContext context, ReadingProvider provider) {
    final otCompleted = provider.getOTCompletedCount();
    final ntCompleted = provider.getNTCompletedCount();
    const totalOT = 728;
    const totalNT = 728;

    final otProgress = (otCompleted / totalOT).clamp(0.0, 1.0);
    final ntProgress = (ntCompleted / totalNT).clamp(0.0, 1.0);

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Bible Reading Progress',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressRow(
            context,
            label: 'Old Testament',
            completed: otCompleted,
            total: totalOT,
            progress: otProgress,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            context,
            label: 'New Testament',
            completed: ntCompleted,
            total: totalNT,
            progress: ntProgress,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(
    BuildContext context, {
    required String label,
    required int completed,
    required int total,
    required double progress,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final percentage = (progress * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$percentage%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$completed out of $total tasks',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyOverview(BuildContext context, List<bool> statuses) {
    final theme = Theme.of(context);
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final todayIndex = DateTime.now().weekday % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isToday = index == todayIndex;
              final isCompleted = statuses[index];

              return Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.1)
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.success
                            : isToday
                                ? AppColors.primary
                                : Colors.grey.shade200,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: AppColors.success)
                          : Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: isToday ? AppColors.primary : Colors.grey,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
