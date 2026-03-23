import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Login Logic
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password,
    );
  }

  // Registration Logic
  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    // 1. Create the Auth Account
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password,
    );

    // 2. Create the User Document in Firestore
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'role': role,
      'commision': 0.0,
      'activeLeads': 0,
      'dealsClosed': 0,
      'wallet': {
        'availableBalance': 0.0,
        'escrowBalance': 0.0,
        'totalEarnings': 0.0,
        'currency': 'NGN',
      },
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();
}