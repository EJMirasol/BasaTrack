import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:basa_track/data/repositories/storage_service.dart';
import 'package:basa_track/data/models/user_progress.dart';
import 'package:basa_track/data/models/daily_schedule.dart';
import 'package:basa_track/data/models/reading_task.dart';
import 'package:basa_track/core/constants/app_constants.dart';
import 'dart:convert';

void main() {
  late StorageService storageService;

  setUp(() async {
    await setUpTestHive();

    PackageInfo.setMockInitialValues(
      appName: 'BasaTrack',
      packageName: 'basa_track',
      version: '9.9.9',
      buildNumber: '9',
      buildSignature: '',
    );

    // Register adapters
    Hive.registerAdapter(DailyScheduleAdapter());
    Hive.registerAdapter(ReadingTaskAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    
    // Open boxes manually for testing
    final schedulesBox = await Hive.openBox<DailySchedule>(AppConstants.hiveBoxSchedules);
    final progressBox = await Hive.openBox<dynamic>(AppConstants.hiveBoxProgress);
    
    storageService = StorageService();
    // Bypass the flutter-dependent initialization
    storageService.setInitializedForTesting(schedulesBox, progressBox);
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('Export and Import data preserves content', () async {
    // 1. Setup initial data
    final progress = UserProgress(
      currentStreak: 5,
      totalDaysRead: 10,
      startDate: DateTime(2023, 1, 1),
    );
    await storageService.saveProgress(progress);

    final schedule = DailySchedule(
      date: DateTime(2023, 10, 1),
      tasks: [],
    );
    await storageService.saveSchedule(schedule);

    // 2. Export
    final exportedJson = await storageService.exportData();
    final Map<String, dynamic> decoded = jsonDecode(exportedJson);
    
    expect(decoded.containsKey('progress'), true);
    expect(decoded.containsKey('schedules'), true);
    expect(decoded['version'], '9.9.9');

    // 3. Clear and Import
    await storageService.clearAll();
    // Verify clear worked
    expect(storageService.getAllSchedules().length, 0);

    await storageService.importData(exportedJson);

    // 4. Verify
    final importedProgress = storageService.getProgress();
    final importedSchedules = storageService.getAllSchedules();

    expect(importedProgress.currentStreak, 5);
    expect(importedProgress.totalDaysRead, 10);
    expect(importedSchedules.length, 1);
    expect(importedSchedules.first.date.year, 2023);
  });
}
