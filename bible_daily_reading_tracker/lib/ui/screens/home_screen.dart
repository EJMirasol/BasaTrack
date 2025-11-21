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
                            'Daily Reading',
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
                            
                            // Date Header
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacing,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    app_date_utils.DateUtils.formatFullDate(
                                      schedule?.date ?? DateTime.now(),
                                    ),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
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
}
