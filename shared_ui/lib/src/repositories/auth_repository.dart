import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'shop_repository.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign in ──────────────────────────────────────────────────────
  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  // ── Sign up ──────────────────────────────────────────────────────
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    if (credential.user != null) {
      await _upsertUserDocument(credential.user!, name: name, role: role);
      
      if (role.toLowerCase() == 'barber') {
        final shopId = await ShopRepository(firestore: _firestore).createShop(
          ownerId: credential.user!.uid,
          name: "$name's Shop",
          address: "Update your address in profile",
        );
        await linkBarberToShop(credential.user!.uid, shopId);
      }
      
      await credential.user?.sendEmailVerification();
    }
    return credential;
  }

  // ── Sign out ─────────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Fetch role ───────────────────────────────────────────────────
  /// Returns null if the document does not exist yet (needs profile completion).
  Future<String?> fetchUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data()?['role'] as String?;
  }

  // ── Stream user ──────────────────────────────────────────────────
  Stream<UserModel?> streamUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromFirestore(doc) : null,
        );
  }

  // ── Ensure / update user document ───────────────────────────────
  Future<void> _upsertUserDocument(
    User user, {
    String? name,
    String? role,
  }) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'name': name ?? user.displayName ?? user.email ?? '',
        'email': user.email ?? '',
        'phone': '',
        'role': role ?? 'customer',
        'profilePicUrl': '',
        'shopId': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Called on first login to ensure document exists.
  Future<void> ensureUserDocument(User user) =>
      _upsertUserDocument(user);

  /// Completes a user's profile (name, phone, role).
  Future<void> completeProfile({
    required String uid,
    required String name,
    required String phone,
    required String role,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'phone': phone,
      'role': role,
    });
  }

  /// Updates barber's shopId after shop creation.
  Future<void> linkBarberToShop(String uid, String shopId) async {
    await _firestore.collection('users').doc(uid).update({'shopId': shopId});
  }

  /// Update profile picture URL.
  Future<void> updateProfilePic(String uid, String url) async {
    await _firestore.collection('users').doc(uid).update({'profilePicUrl': url});
  }

  /// Update user's name, phone, and specialty.
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
    String? specialty,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'phone': phone,
      if (specialty != null) 'specialty': specialty,
    });
  }

  // ── Password reset ───────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  // ── Favorites ────────────────────────────────────────────────────
  Future<void> toggleFavorite(String uid, String shopId,
      {required bool add}) async {
    await _firestore.collection('users').doc(uid).update({
      'favoriteShopIds': add
          ? FieldValue.arrayUnion([shopId])
          : FieldValue.arrayRemove([shopId]),
    });
  }
}
