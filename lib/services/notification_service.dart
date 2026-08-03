// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles FCM background messages even when the app is terminated.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background FCM message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ─── Initialization ───────────────────────────────────────────────────────

  /// Call once at app startup (after Firebase.initializeApp).
  Future<void> initialize() async {
    try {
      // Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Foreground presentation options (iOS / Android 13+)
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
          'FCM foreground: ${message.notification?.title} — ${message.notification?.body}',
        );
      });

      // Notification tap when app is backgrounded (not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('FCM tap (background): ${message.notification?.title}');
      });

      // Notification tap that launched the app from terminated state
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        print('FCM tap (terminated): ${initialMessage.notification?.title}');
      }
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  // ─── Permissions ──────────────────────────────────────────────────────────

  /// Request push notification permissions. Returns true if granted.
  Future<bool> requestPermissions() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }

  // ─── Token Management ─────────────────────────────────────────────────────

  /// Returns the current FCM device token, or null on failure.
  Future<String?> getDeviceToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      print('Error getting FCM device token: $e');
      return null;
    }
  }

  /// Saves the current FCM token to Firestore under `users/{uid}/fcmToken`.
  Future<void> saveTokenToDatabase(String uid) async {
    try {
      final token = await getDeviceToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'fcmToken': token});
        print('FCM token saved to Firestore for uid: $uid');
      }
    } catch (e) {
      print('Error saving FCM token to Firestore: $e');
      // Don't rethrow — token saving failure shouldn't break login flow
    }
  }

  /// Listens for FCM token refreshes and automatically updates Firestore.
  /// Call this once after a successful login.
  void setupTokenRefreshListener(String uid) {
    _fcm.onTokenRefresh.listen((newToken) async {
      print('FCM token refreshed for uid: $uid — updating Firestore...');
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'fcmToken': newToken});
        print('FCM token refresh saved successfully.');
      } catch (e) {
        print('Error saving refreshed FCM token: $e');
      }
    });
  }

  /// Convenience: saves token for the currently signed-in Firebase Auth user.
  Future<void> saveTokenForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await saveTokenToDatabase(user.uid);
    }
  }
}
