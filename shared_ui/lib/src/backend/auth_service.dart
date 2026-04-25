import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/shop_repository.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign In
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign Up and create user document
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (userCredential.user != null) {
      final uid = userCredential.user!.uid;
      print("AuthService: User created with UID: $uid");
      
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'role': role,
          'phone': '',
          'profilePicUrl': '',
          'shopId': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("AuthService: Firestore document created.");
      } catch (e) {
        print("AuthService Error: Firestore write failed: $e");
      }

      if (role.toLowerCase() == 'barber') {
        try {
          final shopId = await ShopRepository().createShop(
            ownerId: uid,
            name: "$name's Shop",
            address: 'Update your address in profile',
          );
          await FirebaseFirestore.instance.collection('users').doc(uid).update({'shopId': shopId});
          print("AuthService: Barber shop created and linked.");
        } catch (e) {
          print("AuthService Error: Barber shop creation failed: $e");
        }
      }
      
      try {
        print("AuthService: Attempting to send verification email...");
        await userCredential.user?.sendEmailVerification();
        print("AuthService: Verification email sent successfully!");
      } catch (e) {
        print("AuthService Error: Failed to send verification email: $e");
      }
    }

    return userCredential;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
