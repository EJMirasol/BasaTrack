import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reading_provider.dart';
import '../../providers/streak_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../widgets/reading_task_card.dart';
import '../widgets/success_message.dart';
import '../widgets/missed_days_alert.dart';
import '../widgets/streak_badge.dart';
import '../animations/celebration_animation.dart';

/// Main home screen of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule data loading for after the first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final readingProvider = context.read<ReadingProvider>();
    final streakProvider = context.read<StreakProvider>();
    
    await Future.wait([
      readingProvider.loadTodaySchedule(),
      streakProvider.loadProgress(),
    ]);
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer2<ReadingProvider, StreakProvider>(
            builder: (context, readingProvider, streakProvider, child) {
              if (readingProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (readingProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          readingProvider.error!,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _onRefresh,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final schedule = readingProvider.currentSchedule;
              final missedDays = readingProvider.getMissedDays();
              final currentStreak = streakProvider.currentStreak;
              final longestStreak = streakProvider.longestStreak;
              final isWeekStreak = streakProvider.hasWeekStreak;

              return CelebrationAnimation(
                show: streakProvider.showWeekStreakCelebration,
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // App Bar
                      SliverAppBar(
                        expandedHeight: 120,
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            'BasaTrAck',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          centerTitle: true,
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Center(
                              child: StreakBadge(
                                currentStreak: currentStreak,
                                longestStreak: longestStreak,
                                isWeekStreak: isWeekStreak,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Content
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            
                            // Week and Day Header
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacing,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Week Number
                                  Text(
                                    'Week ${_getWeekNumber()}',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Day with name
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Day ${_getDayOfWeek()} (${_getDayName()})',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Date
                                  Text(
                                    app_date_utils.DateUtils.formatFullDate(
                                      schedule?.date ?? DateTime.now(),
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),

                            // Missed Days Alert
                            if (missedDays > 0)
                              MissedDaysAlert(missedDays: missedDays),

                            // Week Streak Success Message
                            if (streakProvider.showWeekStreakCelebration)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spacing,
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.secondary,
                                        AppColors.secondaryLight,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadius,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          AppConstants.weekStreakMessage,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          streakProvider
                                              .dismissWeekStreakCelebration();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Progress Indicator
                            if (schedule != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacing,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Today\'s Progress',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Text(
                                          '${schedule.completedCount}/${schedule.totalCount}',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: schedule.completionPercentage,
                                        minHeight: 8,
                                        backgroundColor:
                                            AppColors.textSecondary.withOpacity(0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          schedule.allCompleted
                                              ? AppColors.success
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Success Message (when all tasks completed)
                            if (schedule?.allCompleted == true)
                              const SuccessMessage(),

                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      // Reading Tasks List
                      if (schedule != null)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final task = schedule.tasks[index];
                              return ReadingTaskCard(
                                task: task,
                                onToggle: (checked) {
                                  readingProvider.toggleTask(task.id);
                                  streakProvider.refresh();
                                },
                              );
                            },
                            childCount: schedule.tasks.length,
                          ),
                        ),

                      // Bottom Padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Calculate which day of the 728-day plan we're on
  int _getDayOfPlan() {
    final now = DateTime.now();
    // Plan starts on January 4
    final startDate = DateTime(now.year, 1, 4);
    final daysSinceStart = now.difference(startDate).inDays + 1;
    
    // If before start date, use day 1
    if (daysSinceStart < 1) {
      return 1;
    }
    
    return ((daysSinceStart - 1) % 728) + 1; // Cycle through 728 days
  }

  /// Get current week number (1-104)
  int _getWeekNumber() {
    final dayOfPlan = _getDayOfPlan();
    final weekNumber = ((dayOfPlan - 1) ~/ 7) + 1;
    // Ensure week number is always between 1 and 104
    return weekNumber.clamp(1, 104);
  }

  /// Get current day of week (1-7) based on actual calendar day
  /// Lord's Day (Sunday) = 1, Monday = 2, ..., Saturday = 7
  int _getDayOfWeek() {
    final now = DateTime.now();
    // DateTime.weekday: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7
    // Convert to: Sun=1, Mon=2, Tue=3, Wed=4, Thu=5, Fri=6, Sat=7
    return (now.weekday % 7) + 1;
  }

  /// Get day name
  String _getDayName() {
    final dayOfWeek = _getDayOfWeek();
    switch (dayOfWeek) {
      case 1:
        return "Lord's Day";
      case 2:
        return 'Monday';
      case 3:
        return 'Tuesday';
      case 4:
        return 'Wednesday';
      case 5:
        return 'Thursday';
      case 6:
        return 'Friday';
      case 7:
        return 'Saturday';
      default:
        return '';
    }
  }
}
