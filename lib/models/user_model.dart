import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? fcmToken;
  final String provider; // 'email' | 'google' | 'anonymous'

  // Backward-compat alias so existing code using `.name` still compiles.
  String get name => displayName;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'user',
    required this.createdAt,
    this.lastLoginAt,
    this.fcmToken,
    this.provider = 'email',
  });

  /// Full Firestore document map — all 9 spec fields.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : FieldValue.serverTimestamp(),
      'fcmToken': fcmToken,
      'provider': provider,
    };
  }

  /// Partial update map — only the fields we typically refresh on login.
  Map<String, dynamic> toLoginUpdateMap() {
    return {
      'lastLoginAt': FieldValue.serverTimestamp(),
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      // Support both old 'name' field and new 'displayName'
      displayName: (map['displayName'] as String?)?.isNotEmpty == true
          ? map['displayName'] as String
          : (map['name'] as String? ?? ''),
      photoUrl: map['photoUrl'] as String?,
      role: map['role'] as String? ?? 'user',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
      fcmToken: map['fcmToken'] as String?,
      provider: map['provider'] as String? ?? 'email',
    );
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? role,
    DateTime? lastLoginAt,
    String? fcmToken,
    String? provider,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      fcmToken: fcmToken ?? this.fcmToken,
      provider: provider ?? this.provider,
    );
  }
}
