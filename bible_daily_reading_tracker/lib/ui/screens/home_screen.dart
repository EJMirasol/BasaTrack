import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reading_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../widgets/reading_task_card.dart';
import '../widgets/week_calendar.dart';
import '../widgets/completion_card.dart';
import '../widgets/reminder_card.dart';
import '../widgets/week_streak_card.dart';

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
    final syncProvider = context.read<SyncProvider>();
    
    await Future.wait([
      readingProvider.loadTodaySchedule(),
      streakProvider.loadProgress(),
    ]);
    
    // Trigger sync if online
    await syncProvider.syncAll();
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer4<ReadingProvider, StreakProvider, AuthProvider, SyncProvider>(
          builder: (context, readingProvider, streakProvider, authProvider, syncProvider, child) {
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
            final userName = authProvider.currentUser?.displayName?.split(' ')[0] ?? 'Juan';
            
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting and Menu Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    backgroundImage: authProvider.currentUser?.photoURL != null
                                        ? NetworkImage(authProvider.currentUser!.photoURL!)
                                        : null,
                                    child: authProvider.currentUser?.photoURL == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 20,
                                            color: AppColors.primary,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hi $userName!',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              // Profile Menu
                              PopupMenuButton<void>(
                                icon: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.menu,
                                        size: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Menu',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    enabled: false,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          authProvider.currentUser?.displayName ?? 'User',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (authProvider.currentUser?.email != null)
                                          Text(
                                            authProvider.currentUser!.email!,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          size: 20,
                                          color: Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Sign Out',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      await authProvider.signOut();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Date and Week Number Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    app_date_utils.DateUtils.formatFullDate(
                                      schedule?.date ?? DateTime.now(),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.success.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.bookmark,
                                      size: 14,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Week ${_getWeekNumber()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Week Calendar
                  SliverToBoxAdapter(
                    child: WeekCalendar(
                      weekCompletionStatus: readingProvider.getWeekCompletionStatus(),
                      currentDayIndex: readingProvider.getCurrentDayIndex(),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Reminder Card (when there are missed days)
                  if (readingProvider.hasIncompleteMissedDays())
                    SliverToBoxAdapter(
                      child: ReminderCard(
                        daysLate: readingProvider.getIncompleteMissedDaysCount(),
                      ),
                    ),

                  // Week Streak Celebration (when 7-day streak achieved)
                  if (streakProvider.showWeekStreakCelebration && schedule?.allCompleted == true && !readingProvider.hasIncompleteMissedDays())
                    SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: () {
                          streakProvider.dismissWeekStreakCelebration();
                        },
                        child: const WeekStreakCard(),
                      ),
                    ),

                  // Completion Card (when all tasks completed AND no backlog AND no week streak celebration)
                  if (!streakProvider.showWeekStreakCelebration && schedule?.allCompleted == true && !readingProvider.hasIncompleteMissedDays())
                    const SliverToBoxAdapter(
                      child: CompletionCard(),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Missed Schedules (Backlog) - Show first
                  ...readingProvider.getMissedSchedules().map((missedSchedule) {
                    return SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header for Missed Day
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  app_date_utils.DateUtils.formatFullDate(
                                    missedSchedule.date,
                                  ),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                                Text(
                                  '${missedSchedule.completedCount}/${missedSchedule.totalCount}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Tasks for this missed day
                          ...missedSchedule.tasks.map((task) {
                            return ReadingTaskCard(
                              task: task,
                              onToggle: (checked) async {
                                // Only show confirmation if this is the LAST uncompleted task
                                if (checked && !task.isCompleted) {
                                  // Count how many tasks are currently incomplete
                                  final incompleteTasks = missedSchedule.tasks
                                      .where((t) => !t.isCompleted)
                                      .length;
                                  
                                  // Show confirmation only if this is the last one (1 incomplete task remaining)
                                  if (incompleteTasks == 1) {
                                    final confirmed = await _showBacklogConfirmation(context);
                                    if (!confirmed) {
                                      return; // User cancelled
                                    }
                                  }
                                }
                                
                                await readingProvider.toggleTask(
                                  task.id,
                                  date: missedSchedule.date,
                                );
                                await streakProvider.refresh();
                                // Sync the SPECIFIC DATE, not today!
                                await syncProvider.syncScheduleForDate(missedSchedule.date);
                              },
                            );
                          }).toList(),
                          
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  }).toList(),

                  // Today's Schedule Header (only show if not all backlog complete)
                  if (schedule != null)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today - ${app_date_utils.DateUtils.formatFullDate(schedule.date)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${schedule.completedCount}/${schedule.totalCount}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Today's Reading Tasks List
                  if (schedule != null)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = schedule.tasks[index];
                          return ReadingTaskCard(
                            task: task,
                            onToggle: (checked) async {
                              await readingProvider.toggleTask(task.id);
                              await streakProvider.refresh();
                              await syncProvider.syncTodaySchedule();
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
            );
          },
        ),
      ),
    );
  }

  /// Show confirmation dialog before allowing backlog task completion
  Future<bool> _showBacklogConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Confirm Completion'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are about to mark a backlog task as complete.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Once checked, this action CANNOT be undone.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Do you want to proceed?',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
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
}
