import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import '../services/hive_service.dart';
import '../models/user.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserInfo? _currentUser;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  bool _isAuthLoading = false;

  // Getters
  UserInfo? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthLoading => _isAuthLoading;

  UserProvider() {
    _currentUser = HiveService.instance.currentUser!;

    _auth.authStateChanges().listen((User? user) {
      if (user != null){
        syncUserWithFirestore(user.uid);
      } else {
        _handleLogout();
      }
    });
  }

  Future<void> syncUserWithFirestore(String uid) async {
    _setLoading(true);

    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();

      if(doc.exists) {
        // Map data to user model
        final newUser = UserInfo.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        // update user in hive
        await HiveService.instance.saveUser(newUser);

        // update local state and notify listeners
        _currentUser = newUser;
        notifyListeners();
      }
    } catch (e, stack) {
      if(e is FirebaseException && e.code == 'unavailable') {
        // Show snackbar for network issue
      } else {
        await FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Failed to sync user $uid from Firestore');

        FirebaseCrashlytics.instance.setCustomKey('user_id', uid);
        FirebaseCrashlytics.instance.log('sync error occurred in UserProvider');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> signUpUser(String email, String password, String name, String role) async {
    _isAuthLoading = true;
    notifyListeners();

    try {
      await _authService.registerUser(
        email: email, 
        password: password, 
        name: name, 
        role: role
      );
      return null; // Success (No error message)
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the error to show in the UI
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<String?> loginUser(String email, String password) async {
    _setAuthLoading(true);
    
    try {
      // 1. Authenticate with Firebase Auth
      UserCredential credential = await _authService.login(email, password);
      
      // 2. Sync their Firestore profile to Hive (Reuse our existing logic)
      if (credential.user != null) {
        await syncUserWithFirestore(credential.user!.uid);
      }
      
      return null; // Return null if there's no error (Success)
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors (Wrong password, user not found, etc.)
      return e.message ?? "An authentication error occurred.";
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
    } finally {
      _setAuthLoading(false);
    }
  }

  Future<String?> resetPassword(String email) async {
    _setAuthLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email.trim());
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Could not send reset email.";
    } catch (e) {
      return "An unexpected error occurred.";
    } finally {
      _setAuthLoading(false);
    }
  }

  void _setAuthLoading(bool value) {
    _isAuthLoading = value;
    notifyListeners();
  }

  Future<void> _handleLogout() async {
    await HiveService.instance.clearAll();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}