part of 'user_cubit.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  UserLoaded({required this.user});

  // Convenience getters used widely in UI
  String get name => user.name;
  String get email => user.email;
  String get phone => user.phone;
  String get role => user.role;
  String get profilePicUrl => user.profilePicUrl;
  String get shopId => user.shopId;
}

class UserError extends UserState {}
