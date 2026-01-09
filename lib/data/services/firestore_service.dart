import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_schedule.dart';
import '../models/user_progress.dart';

/// Service for managing Firestore data operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize Firestore settings
  FirestoreService() {
    // Enable offline persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Collection paths
  String _progressPath(String userId) => 'users/$userId/progress';
  String _schedulesPath(String userId) => 'users/$userId/schedules';

  /// Save user progress to Firestore
  Future<void> saveUserProgress(String userId, UserProgress progress) async {
    try {
      await _firestore
          .collection(_progressPath(userId))
          .doc('current')
          .set(progress.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to save user progress: $e');
    }
  }

  /// Get user progress from Firestore
  Future<UserProgress?> getUserProgress(String userId) async {
    try {
      final doc = await _firestore
          .collection(_progressPath(userId))
          .doc('current')
          .get();
      
      if (!doc.exists) {
        return null;
      }

      return UserProgress.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw FirestoreException('Failed to get user progress: $e');
    }
  }

  /// Save daily schedule to Firestore
  Future<void> saveDailySchedule(
    String userId,
    DailySchedule schedule,
  ) async {
    try {
      final dateKey = _getDateKey(schedule.date);
      await _firestore
          .doc('${_schedulesPath(userId)}/$dateKey')
          .set(schedule.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to save daily schedule: $e');
    }
  }

  /// Get daily schedule from Firestore
  Future<DailySchedule?> getDailySchedule(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateKey = _getDateKey(date);
      final doc = await _firestore
          .doc('${_schedulesPath(userId)}/$dateKey')
          .get();

      if (!doc.exists) {
        return null;
      }

      return DailySchedule.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw FirestoreException('Failed to get daily schedule: $e');
    }
  }

  /// Get all schedules for a user
  Future<List<DailySchedule>> getAllSchedules(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_schedulesPath(userId))
          .get();

      return querySnapshot.docs
          .map((doc) => DailySchedule.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to get all schedules: $e');
    }
  }

  /// Batch save schedules (for migration)
  Future<void> batchSaveSchedules(
    String userId,
    List<DailySchedule> schedules,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final schedule in schedules) {
        final dateKey = _getDateKey(schedule.date);
        final docRef = _firestore.doc('${_schedulesPath(userId)}/$dateKey');
        batch.set(docRef, schedule.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to batch save schedules: $e');
    }
  }

  /// Listen to user progress changes (real-time sync)
  Stream<UserProgress?> listenToUserProgress(String userId) {
    return _firestore
        .collection(_progressPath(userId))
        .doc('current')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProgress.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// Listen to daily schedule changes (real-time sync)
  Stream<DailySchedule?> listenToDailySchedule(
    String userId,
    DateTime date,
  ) {
    final dateKey = _getDateKey(date);
    return _firestore
        .doc('${_schedulesPath(userId)}/$dateKey')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return DailySchedule.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// Delete all user data (for account deletion)
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete progress
      await _firestore
          .collection(_progressPath(userId))
          .doc('current')
          .delete();

      // Delete all schedules
      final schedulesQuery = await _firestore
          .collection(_schedulesPath(userId))
          .get();

      final batch = _firestore.batch();
      for (final doc in schedulesQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to delete user data: $e');
    }
  }

  /// Generate a consistent date key
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Custom exception for Firestore errors
class FirestoreException implements Exception {
  final String message;

  FirestoreException(this.message);

  @override
  String toString() => message;
}
