import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final AuthRepository _repo;
  StreamSubscription<UserModel?>? _subscription;

  UserCubit({AuthRepository? repo})
      : _repo = repo ?? AuthRepository(),
        super(UserInitial());

  /// Starts streaming the user document from Firestore.
  void streamUser(String uid) {
    _subscription?.cancel();
    emit(UserLoading());
    _subscription = _repo.streamUser(uid).listen(
      (user) {
        if (user != null) {
          emit(UserLoaded(user: user));
        } else {
          emit(UserInitial());
        }
      },
      onError: (_) => emit(UserInitial()),
    );
  }

  /// One-shot load (legacy support).
  Future<void> loadUser(String uid) => Future(() => streamUser(uid));

  Future<void> updateProfilePic(String uid, String url) async {
    await _repo.updateProfilePic(uid, url);
  }

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
    String? specialty,
  }) async {
    await _repo.updateProfile(uid: uid, name: name, phone: phone, specialty: specialty);
  }

  Future<void> toggleFavorite(String uid, String shopId,
      {required bool add}) async {
    await _repo.toggleFavorite(uid, shopId, add: add);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
