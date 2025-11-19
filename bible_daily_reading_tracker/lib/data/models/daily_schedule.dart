import 'package:hive/hive.dart';
import 'reading_task.dart';

part 'daily_schedule.g.dart';

/// Represents the daily reading schedule
@HiveType(typeId: 1)
class DailySchedule extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<ReadingTask> tasks;

  DailySchedule({
    required this.date,
    required this.tasks,
  });

  /// Check if all tasks are completed
  bool get allCompleted => tasks.isNotEmpty && tasks.every((task) => task.isCompleted);

  /// Get completion percentage
  double get completionPercentage {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((task) => task.isCompleted).length;
    return completed / tasks.length;
  }

  /// Get number of completed tasks
  int get completedCount => tasks.where((task) => task.isCompleted).length;

  /// Get total number of tasks
  int get totalCount => tasks.length;

  /// Check if this is today's schedule
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Create a copy with updated fields
  DailySchedule copyWith({
    DateTime? date,
    List<ReadingTask>? tasks,
  }) {
    return DailySchedule(
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory DailySchedule.fromJson(Map<String, dynamic> json) {
    return DailySchedule(
      date: DateTime.parse(json['date'] as String),
      tasks: (json['tasks'] as List<dynamic>)
          .map((taskJson) => ReadingTask.fromJson(taskJson as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() =>
      'DailySchedule(date: $date, tasks: ${tasks.length}, completed: $completedCount/$totalCount)';
}
