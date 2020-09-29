import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class BaseAuth {
  Future<void> init();
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> resetUserWithEmail(String email);
  Future<String> currentUser();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> init() async {
    Firebase.initializeApp();
  }

  @override
  Future<String> signInWithEmailAndPassword(String email, String password) async {
    final UserCredential user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.user.uid;
  }

  @override
  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    final UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.user.uid;
  }

  @override
  Future<String> resetUserWithEmail(String email) async {
    final user = await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<String> currentUser() async {
    final User user = _firebaseAuth.currentUser;
    return user != null ? user.uid : null;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}