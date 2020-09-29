import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Stream<String> get onAuthStateChanged => _firebaseAuth.authStateChanges().map(
        (User user) => user?.uid,
  );

  // GET UID
  Future<String> getCurrentUID() async {
    return (_firebaseAuth.currentUser).uid;
  }

  // GET CURRENT USER
  Future getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  // Email & Password Sign Up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );
    // Update the username
    await updateUserName(name, authResult.user);
    return authResult.user.uid;
  }

  Future updateUserName(String name, User currentUser) async {
    await currentUser.updateProfile(displayName: name);
    await currentUser.reload();
  }



  // Email & Password Sign In
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password))
        .user
        .uid;
  }

  // Sign Out
  signOut() async {
    return await _firebaseAuth.signOut();
  }

  // Reset Password
  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

class NameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Name can't be empty";
    }
    if (value.length < 2) {
      return "Name must be at least 2 characters long";
    }
    if (value.length > 50) {
      return "Name must be less than 50 characters long";
    }
    return null;
  }
}

class EmailValidator {
  static String validate(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@sret.edu.in+";
    RegExp regex = new RegExp(pattern);
    if(value.isEmpty){
      return 'Email is required.';
    }
    else if (!regex.hasMatch(value))
      return 'Enter a valid E-Mail.';
    else
      return null;
  }
}

class PasswordValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Password can't be empty";
    }
    return null;
  }
}