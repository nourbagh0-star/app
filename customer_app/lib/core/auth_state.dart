import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  static void login() {
    // No-op. FirebaseAuth state is updated via Firebase sign_in methods.
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
