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
import '../widgets/notification_permission_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      _checkAndRequestNotificationPermission();
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

  /// Check if notification permission has been requested and show dialog if needed
  Future<void> _checkAndRequestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    const String permissionRequestedKey = 'notification_permission_requested';
    
    // Check if we've already asked for permission
    final bool hasAskedBefore = prefs.getBool(permissionRequestedKey) ?? false;
    
    if (!hasAskedBefore && mounted) {
      // Wait a bit for the UI to settle
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        // Show the permission dialog
        await NotificationPermissionDialog.show(context);
        
        // Mark that we've asked for permission
        await prefs.setBool(permissionRequestedKey, true);
      }
    }
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
                    const Icon(
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
                          // Empty header row to maintain spacing if needed, or just remove
                          const SizedBox(height: 8),
                          
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
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.success.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.bookmark,
                                      size: 14,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateTime.now().isBefore(app_date_utils.DateUtils.planStartDate)
                                          ? 'Not Started'
                                          : 'Week ${_getWeekNumber()}',
                                      style: const TextStyle(
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
                  if (streakProvider.showWeekStreakCelebration && schedule?.allCompleted == true)
                    SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: () {
                          streakProvider.dismissWeekStreakCelebration();
                        },
                        child: const WeekStreakCard(),
                      ),
                    ),

                  // Plan Not Started Message
                  if (DateTime.now().isBefore(app_date_utils.DateUtils.planStartDate))
                    SliverToBoxAdapter(
                      child: _buildPlanNotStartedCard(theme),
                    ),

                  // Completion Card (when all tasks completed AND no backlog AND no week streak celebration)
                  if (!streakProvider.showWeekStreakCelebration && schedule?.allCompleted == true && !readingProvider.hasIncompleteMissedDays())
                    const SliverToBoxAdapter(
                      child: CompletionCard(),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Missed Schedules (Backlog) - Show first
                  if (!DateTime.now().isBefore(app_date_utils.DateUtils.planStartDate))
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
                          }),
                          
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  }),

                  // Today's Schedule Header (only show if not all backlog complete)
                  if (schedule != null && !DateTime.now().isBefore(app_date_utils.DateUtils.planStartDate))
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
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
                  if (schedule != null && !DateTime.now().isBefore(app_date_utils.DateUtils.planStartDate))
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

  /// Get current week number (1-104)
  int _getWeekNumber() {
    final readingProvider = context.read<ReadingProvider>();
    final scheduleDate = readingProvider.currentSchedule?.date ?? DateTime.now();
    return app_date_utils.DateUtils.getPlanWeek(scheduleDate);
  }

  /// Builds a card to inform the user that the reading plan hasn't started yet
  Widget _buildPlanNotStartedCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_available,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Reading Plan Starts Soon!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'The official Bible reading plan begins on January 4, 2026. Your first tasks will appear here on that day.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Mark your calendar!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
