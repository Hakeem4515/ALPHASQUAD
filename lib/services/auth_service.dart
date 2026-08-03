// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database_service.dart';
import 'notification_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notifService = NotificationService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '648204198244-am4vl9jsf20bj7qi9uu4e8iu3utanq1k.apps.googleusercontent.com',
  );

  // ─── State ────────────────────────────────────────────────────────────────

  /// Currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Stream that emits auth state changes (login / logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Email / Password ─────────────────────────────────────────────────────

  /// Registers a new user and creates their Firestore profile document.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      // Update Firebase Auth display name
      await user.updateDisplayName(name);

      // Get FCM token (non-blocking — null is acceptable)
      final fcmToken = await _notifService.getDeviceToken();

      // Create full Firestore user document
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: name,
        photoUrl: null,
        role: 'user',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        fcmToken: fcmToken,
        provider: 'email',
      );
      await _dbService.createUserProfile(userModel);

      // Start listening for future token refreshes
      _notifService.setupTokenRefreshListener(user.uid);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('Error in signUpWithEmailAndPassword: $e');
      rethrow;
    }
  }

  /// Signs in an existing user and refreshes lastLoginAt + fcmToken in Firestore.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _postLoginActions(credential.user!.uid);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('Error in signInWithEmailAndPassword: $e');
      rethrow;
    }
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  /// Signs in with Google. Creates a Firestore document for new users,
  /// or updates lastLoginAt + fcmToken for returning users.
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger Google account picker
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled by the user.');
      }

      // Obtain auth tokens
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign into Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final fcmToken = await _notifService.getDeviceToken();
      final alreadyExists = await _dbService.userExists(user.uid);

      if (alreadyExists) {
        // Returning Google user — update login timestamp and FCM token
        await _dbService.updateUserProfile(user.uid, {
          'lastLoginAt': DateTime.now().toIso8601String(),
          'fcmToken': fcmToken,
        });
      } else {
        // New Google user — create full Firestore profile
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? googleUser.displayName ?? '',
          photoUrl: user.photoURL,
          role: 'user',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          fcmToken: fcmToken,
          provider: 'google',
        );
        await _dbService.upsertUserProfile(userModel);
      }

      // Start listening for future token refreshes
      _notifService.setupTokenRefreshListener(user.uid);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('Error in signInWithGoogle: $e');
      rethrow;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      // Sign out from Google if that was the provider
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // ─── Password Reset ───────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  /// Refreshes lastLoginAt and fcmToken after any successful sign-in.
  Future<void> _postLoginActions(String uid) async {
    try {
      final fcmToken = await _notifService.getDeviceToken();
      await _dbService.updateUserProfile(uid, {
        'lastLoginAt': DateTime.now().toIso8601String(),
        'fcmToken': ?fcmToken,
      });
      _notifService.setupTokenRefreshListener(uid);
    } catch (e) {
      // Non-fatal: login still succeeds even if Firestore update fails
      print('Warning: post-login Firestore update failed: $e');
    }
  }

  /// Maps FirebaseAuthException codes to user-friendly English messages.
  Exception _handleAuthException(FirebaseAuthException e) {
    final messages = {
      'email-already-in-use':
          'This email is already registered. Try logging in instead.',
      'invalid-email': 'Please enter a valid email address.',
      'weak-password': 'Password must be at least 6 characters.',
      'user-not-found': 'No account found with this email.',
      'wrong-password': 'Incorrect password. Please try again.',
      'too-many-requests': 'Too many failed attempts. Please try again later.',
      'network-request-failed': 'Network error. Please check your connection.',
      'user-disabled': 'This account has been disabled. Contact support.',
      'operation-not-allowed': 'This sign-in method is not enabled.',
      'account-exists-with-different-credential':
          'An account already exists with this email using a different sign-in method.',
      'invalid-credential': 'Invalid credentials. Please try again.',
    };
    final message = messages[e.code] ?? 'Authentication error: ${e.message}';
    print('FirebaseAuthException [${e.code}]: ${e.message}');
    return Exception(message);
  }
}
