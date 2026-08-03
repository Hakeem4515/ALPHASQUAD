// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/solar_system_model.dart';
import '../models/alert_model.dart';
import '../models/system_settings_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── User Profile ─────────────────────────────────────────────────────────

  /// Creates a new user document (overwrites if already exists).
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user profile in Firestore: $e');
      rethrow;
    }
  }

  /// Creates or merges a user document — safe for Google Sign-In (new & existing users).
  Future<void> upsertUserProfile(UserModel user) async {
    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error upserting user profile in Firestore: $e');
      rethrow;
    }
  }

  /// Returns true if a Firestore document already exists for the given UID.
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile from Firestore: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user profile in Firestore: $e');
      rethrow;
    }
  }

  // ─── Solar Systems ────────────────────────────────────────────────────────

  Future<void> saveSolarSystem(SolarSystemModel system) async {
    try {
      await _db.collection('solar_systems').doc(system.id).set(system.toMap());
    } catch (e) {
      print('Error saving solar system: $e');
      rethrow;
    }
  }

  Stream<List<SolarSystemModel>> streamUserSolarSystems(String userId) {
    return _db
        .collection('solar_systems')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SolarSystemModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> updateSolarSystemLight(String systemId, bool isLightOn) async {
    try {
      await _db
          .collection('solar_systems')
          .doc(systemId)
          .update({'isLightOn': isLightOn, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error updating solar system light status: $e');
      rethrow;
    }
  }

  // ─── Alerts ───────────────────────────────────────────────────────────────

  Future<void> saveAlert(AlertModel alert) async {
    try {
      await _db.collection('alerts').doc(alert.id).set(alert.toMap());
    } catch (e) {
      print('Error saving alert: $e');
      rethrow;
    }
  }

  Stream<List<AlertModel>> streamUserAlerts(String userId) {
    return _db
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AlertModel.fromMap(doc.data())).toList());
  }

  Future<void> dismissAlert(String alertId) async {
    try {
      await _db.collection('alerts').doc(alertId).update({'isDismissed': true});
    } catch (e) {
      print('Error dismissing alert: $e');
      rethrow;
    }
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  Future<void> saveSystemSettings(String userId, SystemSettingsModel settings) async {
    try {
      await _db.collection('settings').doc(userId).set(settings.toMap());
    } catch (e) {
      print('Error saving system settings: $e');
      rethrow;
    }
  }

  Future<SystemSettingsModel?> getSystemSettings(String userId) async {
    try {
      final doc = await _db.collection('settings').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return SystemSettingsModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting system settings: $e');
      rethrow;
    }
  }
}
