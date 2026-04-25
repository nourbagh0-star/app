import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit({AuthRepository? repo})
      : _repo = repo ?? AuthRepository(),
        super(AuthInitial());

  void init() {
    _authSubscription = _repo.authStateChanges.listen(
      (user) async {
        if (user == null) {
          emit(AuthUnauthenticated());
          return;
        }
        await _resolveUserState(user);
      },
      onError: (e) => emit(AuthError(e.toString())),
    );
  }

  Future<void> _resolveUserState(User user) async {
    try {
      await _repo.ensureUserDocument(user);
      final role = await _repo.fetchUserRole(user.uid);
      if (role == null || role.isEmpty) {
        emit(AuthNeedsProfileCompletion(user));
      } else if (role == 'barber') {
        emit(AuthBarber(user));
      } else {
        emit(AuthCustomer(user));
      }
    } catch (e) {
      emit(AuthError('Failed to load user role. Please sign in again.'));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _repo.signIn(email, password);
      // State resolved via authStateChanges stream
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Sign in failed'));
    }
  }

  Future<void> signUp(
      String email, String password, String name, String role) async {
    emit(AuthLoading());
    try {
      await _repo.signUp(
          email: email, password: password, name: name, role: role);
      // State resolved via authStateChanges stream
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Sign up failed'));
    }
  }

  Future<void> completeProfile({
    required String uid,
    required String name,
    required String phone,
    required String role,
  }) async {
    emit(AuthLoading());
    try {
      await _repo.completeProfile(
          uid: uid, name: name, phone: phone, role: role);
      final user = _repo.currentUser;
      if (user != null) await _resolveUserState(user);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
