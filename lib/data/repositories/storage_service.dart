import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_schedule.dart';
import '../models/reading_task.dart';
import '../models/user_progress.dart';
import '../../core/constants/app_constants.dart';

/// Service for managing local storage using Hive
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Box<DailySchedule>? _schedulesBox;
  Box<dynamic>? _progressBox;

  bool _isInitialized = false;

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ReadingTaskAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(DailyScheduleAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(UserProgressAdapter());
      }

      // Open boxes
      _schedulesBox = await Hive.openBox<DailySchedule>(
        AppConstants.hiveBoxSchedules,
      );
      _progressBox = await Hive.openBox(
        AppConstants.hiveBoxProgress,
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Save daily schedule
  Future<void> saveSchedule(DailySchedule schedule) async {
    await _ensureInitialized();
    final key = _getDateKey(schedule.date);
    await _schedulesBox!.put(key, schedule);
  }

  /// Get daily schedule by date
  DailySchedule? getSchedule(DateTime date) {
    _ensureInitializedSync();
    final key = _getDateKey(date);
    return _schedulesBox!.get(key);
  }

  /// Save user progress
  Future<void> saveProgress(UserProgress progress) async {
    await _ensureInitialized();
    await _progressBox!.put(AppConstants.keyUserProgress, progress);
  }

  /// Get user progress
  UserProgress getProgress() {
    _ensureInitializedSync();
    final progress = _progressBox!.get(AppConstants.keyUserProgress);
    
    if (progress == null) {
      // Return new progress if none exists
      return UserProgress();
    }
    
    // Handle both UserProgress objects and JSON maps
    if (progress is UserProgress) {
      return progress;
    } else if (progress is Map) {
      return UserProgress.fromJson(Map<String, dynamic>.from(progress));
    }
    
    return UserProgress();
  }

  /// Get all saved schedules
  List<DailySchedule> getAllSchedules() {
    _ensureInitializedSync();
    return _schedulesBox!.values.toList();
  }

  /// Delete schedule by date
  Future<void> deleteSchedule(DateTime date) async {
    await _ensureInitialized();
    final key = _getDateKey(date);
    await _schedulesBox!.delete(key);
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _schedulesBox!.clear();
    await _progressBox!.clear();
  }

  /// Export all data as a JSON string
  Future<String> exportData() async {
    await _ensureInitialized();
    
    final Map<String, dynamic> data = {
      'version': AppConstants.appVersion,
      'exportDate': DateTime.now().toIso8601String(),
      'schedules': {},
      'progress': getProgress().toJson(),
    };

    final schedules = _schedulesBox!.toMap();
    final Map<String, dynamic> schedulesJson = {};
    schedules.forEach((key, value) {
      schedulesJson[key.toString()] = value.toJson();
    });
    data['schedules'] = schedulesJson;

    return jsonEncode(data);
  }

  /// Import data from a JSON string
  Future<void> importData(String jsonData) async {
    await _ensureInitialized();
    
    final Map<String, dynamic> data = jsonDecode(jsonData);

    // Validate version or structure if needed
    if (!data.containsKey('progress') || !data.containsKey('schedules')) {
      throw Exception('Invalid fallback data format');
    }

    // Clear existing data
    await clearAll();

    // Import progress
    final progressJson = data['progress'] as Map<String, dynamic>;
    await saveProgress(UserProgress.fromJson(progressJson));

    // Import schedules
    final schedulesJson = data['schedules'] as Map<String, dynamic>;
    for (final entry in schedulesJson.entries) {
      final schedule = DailySchedule.fromJson(entry.value as Map<String, dynamic>);
      await _schedulesBox!.put(entry.key, schedule);
    }
  }

  /// Generate a consistent key for a date
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Ensure storage is initialized (async)
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Ensure storage is initialized (sync)
  void _ensureInitializedSync() {
    if (!_isInitialized) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
  }

  /// Close all boxes (cleanup)
  Future<void> close() async {
    await _schedulesBox?.close();
    await _progressBox?.close();
    _isInitialized = false;
  }

  /// Manually set the initialized state for testing
  @visibleForTesting
  void setInitializedForTesting(
    Box<DailySchedule> schedulesBox,
    Box<dynamic> progressBox,
  ) {
    _schedulesBox = schedulesBox;
    _progressBox = progressBox;
    _isInitialized = true;
  }
}
