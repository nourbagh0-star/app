part of 'shop_cubit.dart';

abstract class ShopState {}

class ShopInitial extends ShopState {}

class ShopsLoading extends ShopState {}

class ShopsLoaded extends ShopState {
  final List<ShopModel> shops;
  ShopsLoaded(this.shops);
}

class ShopDetailLoading extends ShopState {}

class ShopDetailLoaded extends ShopState {
  final ShopModel shop;
  ShopDetailLoaded(this.shop);
}

class ShopError extends ShopState {
  final String message;
  ShopError(this.message);
}
