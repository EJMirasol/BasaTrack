import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Represents an authenticated user in the app
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final bool isGuest;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    DateTime? createdAt,
    this.lastSignInAt,
    this.isGuest = false,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a guest user
  factory AppUser.guest() {
    return AppUser(
      uid: 'guest_${const Uuid().v4()}',
      displayName: 'Guest',
      isGuest: true,
    );
  }

  /// Create a copy with updated fields
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool? isGuest,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'isGuest': isGuest,
    };
  }

  /// Create from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastSignInAt: json['lastSignInAt'] != null
          ? DateTime.parse(json['lastSignInAt'] as String)
          : null,
      isGuest: json['isGuest'] as bool? ?? false,
    );
  }

  /// Create from Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, displayName: $displayName, isGuest: $isGuest)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
