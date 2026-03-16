import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _currentUser;

  bool get keyIsAdmin => _currentUser?.role == UserRole.admin;
  bool get keyIsClerk => _currentUser?.role == UserRole.clerk;
  bool get keyCanEdit => keyIsAdmin || keyIsClerk;

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (doc.exists) {
          _currentUser = User.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        } else {
          _currentUser = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Unknown',
            email: firebaseUser.email ?? '',
            role: UserRole.user,
          );
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        _currentUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Unknown',
          email: firebaseUser.email ?? '',
          role: UserRole.user,
        );
      }
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
