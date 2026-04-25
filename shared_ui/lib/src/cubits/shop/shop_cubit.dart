import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/shop_model.dart';
import '../../repositories/shop_repository.dart';

part 'shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  final ShopRepository _repo;
  StreamSubscription<List<ShopModel>>? _subscription;

  ShopCubit({ShopRepository? repo})
      : _repo = repo ?? ShopRepository(),
        super(ShopInitial());

  /// Streams all approved shops (home screen list).
  void loadShops() {
    emit(ShopsLoading());
    _subscription?.cancel();
    _subscription = _repo.streamApprovedShops().listen(
      (shops) => emit(ShopsLoaded(shops)),
      onError: (e) => emit(ShopError(e.toString())),
    );
  }

  /// Fetches a single shop with its services and barbers.
  Future<void> loadShopDetails(String shopId) async {
    emit(ShopDetailLoading());
    try {
      final shop = await _repo.fetchShopWithDetails(shopId);
      emit(ShopDetailLoaded(shop));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
