import 'package:hive/hive.dart';

part 'reading_task.g.dart';

/// Represents a single Bible reading task
@HiveType(typeId: 0)
class ReadingTask extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String reference;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime? completedAt;

  ReadingTask({
    required this.id,
    required this.reference,
    this.isCompleted = false,
    this.completedAt,
  });

  /// Toggle completion status
  void toggleCompletion() {
    isCompleted = !isCompleted;
    completedAt = isCompleted ? DateTime.now() : null;
  }

  /// Create a copy with updated fields
  ReadingTask copyWith({
    String? id,
    String? reference,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return ReadingTask(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ReadingTask.fromJson(Map<String, dynamic> json) {
    return ReadingTask(
      id: json['id'] as String,
      reference: json['reference'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  String toString() => 
      'ReadingTask(id: $id, reference: $reference, isCompleted: $isCompleted)';
}
